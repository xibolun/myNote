---
date :  "2019-08-29T19:08:49+08:00" 
title : "Go pprof" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### 什么是pprof

pprof是一个收集profiling数据样本，用于可视化展示和分析程序性能的工具，有cpu、内存、trace、Goroutine等。

go语言的工具包里面的自带pprof；

```shell
➜  darwin_amd64 pwd
/usr/local/go1.12.0/pkg/tool/darwin_amd64
➜  darwin_amd64 ll
......
-rwxr-xr-x  1 root  wheel    14M Jul  9 05:30 pprof
```

```
➜  ~ go tool pprof --help                                                      
usage:                                                                         
                                                                               
Produce output in the specified format.                                        
                                                                               
   pprof <format> [options] [binary] <source> ...                              
                                                                               
Omit the format to get an interactive shell whose commands can be used         
to generate various views of a profile                                         
                                                                               
   pprof [options] [binary] <source> ...                                       
                                                                               
Omit the format and provide the "-http" flag to get an interactive web
interface at the specified host:port that can be used to navigate through
various views of a profile.

   pprof -http [host]:[port] [options] [binary] <source> ...                                                 
```

### 启用

如果想使用http请求访问可以参考官方的说明 [overview](https://golang.org/pkg/net/http/pprof/#pkg-overview), 里面讲述了如何使用，并同时给了一些常用的url示意；

```go
go func() {
	log.Println(http.ListenAndServe("localhost:6060", nil))
}()
```

或者自己写http请求也可以，以下是我在iris里面添加的一些代码；但是未注册的好像请求不了；所以建议还是使用官方推荐的方式

```go
// RegisterPProf pprof相关注册
// 以下url未注册  /debug/pprof/heap、goroutines、
func RegisterPProf(app *iris.Application) {
	app.Get("/debug/pprof/", route.PProfIndexHandle())
	app.Get("/debug/pprof/cmdline", route.PProfCmdlineHandle())
	app.Get("/debug/pprof/profile", route.PProfProfileHandle())
	app.Get("/debug/pprof/symbol", route.PProfSymbolHandle())
	app.Get("/debug/pprof/trace", route.PProfTraceHandle())
}
```

后来看了一下 [评论](https://artem.krylysov.com/blog/2017/03/13/profiling-and-optimizing-go-web-applications/#comment-3640502941) 是可以实现的； 如果想全量补充，可以使用以下方式：

```go
func RegisterPProf(app *iris.Application) {
	app.Get("/debug/pprof/", route.PProfIndexHandle())
	app.Get("/debug/{code:string}", route.PProfHandle())
}

// PProfHandle
func PProfHandle() context.Handler {
	return hero.Register(func(ctx iris.Context) (code string, _ctx iris.Context) {
		code = ctx.URLParam("code")
		return code, ctx
	}).Handler(func(code string, ctx iris.Context) {
		fmt.Printf("url param code is : %s\n", code)
		switch code {
		case "cmdline":
			pprof.Cmdline(ctx.ResponseWriter(), ctx.Request())
		case "symbol":
			pprof.Symbol(ctx.ResponseWriter(), ctx.Request())
		case "trace":
			pprof.Trace(ctx.ResponseWriter(), ctx.Request())
		case "profile":
			pprof.Profile(ctx.ResponseWriter(), ctx.Request())
		case "allocs":
			pprof.Handler("allocs").ServeHTTP(ctx.ResponseWriter(), ctx.Request())
		case "block":
			pprof.Handler("block").ServeHTTP(ctx.ResponseWriter(), ctx.Request())
		case "goroutine":
			pprof.Handler("goroutine").ServeHTTP(ctx.ResponseWriter(), ctx.Request())
		case "heap":
			pprof.Handler("heap").ServeHTTP(ctx.ResponseWriter(), ctx.Request())
		case "mutex":
			pprof.Handler("mutex").ServeHTTP(ctx.ResponseWriter(), ctx.Request())
		case "threadcreate":
			pprof.Handler("threadcreate").ServeHTTP(ctx.ResponseWriter(), ctx.Request())
		default:
			pprof.Index(ctx.ResponseWriter(), ctx.Request())
		}
	})
}
```

还有一种方式是使用`runtime`包进行代码操作；这种方式可以用于非http请求的应用，运行一段时间就结束的那种

```go
f, err := os.Create(*cpuprofile)
...
pprof.StartCPUProfile(f)
defer pprof.StopCPUProfile()
...
f, err := os.Create(*memprofile)
pprof.WriteHeapProfile(f)
f.Close()
```

### 使用

由于可视化使用了 [Graphviz](https://www.graphviz.org/) 来生成关系图和火焰图，所以需要安装一下；

第一种方式：可以将文件下载下来，然后另启一个http端口号

```shell
curl -O http://localhost:6060/debug/pprof/heap /Users/admin/projects/go/source/heap
go tool pprof -http=":8080" /Users/admin/projects/go/source/heap
```

或者直接使用交互模式；可以看到交互模式是先将文件下载下来，然后存放到pprof文件夹下，然后可以使用一些命令和选项进行分析

```shell
➜  ~ go tool pprof http://localhost:6060/debug/pprof/heap
Fetching profile over HTTP from http://localhost:6060/debug/pprof/heap
Saved profile in /Users/admin/pprof/pprof.alloc_objects.alloc_space.inuse_objects.inuse_space.003.pb.gz
Type: inuse_space
Time: Aug 31, 2019 at 10:00pm (CST)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) 
```

### 参考：

- [Go blog介绍](https://blog.golang.org/profiling-go-programs)
- [赫林写的go命令教程](https://github.com/hyper0x/go_command_tutorial/blob/master/0.12.md)
- [俄罗斯一哥们写的blog](https://artem.krylysov.com/blog/2017/03/13/profiling-and-optimizing-go-web-applications/)

