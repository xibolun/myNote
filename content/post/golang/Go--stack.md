---

date :  "2018-12-07T22:20:49+08:00" 
title : "GO stack" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true

---

### 将http panic日志打印至文件当中

创建文件

```go
panicFile, err := os.OpenFile(conf.Logger.PanicLogFile, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
if err != nil {
   return nil, err
}
```

注入文件

```go
r.Use(mw.InjectFile(panicFile))
```

```go
// InjectFile 注入Panic File
func InjectFile(panic *os.File) func(next http.Handler) http.Handler {
   return func(next http.Handler) http.Handler {
      fn := func(w http.ResponseWriter, r *http.Request) {
         r = r.WithContext(context.WithValue(r.Context(), &panicFileKey, panic))
         next.ServeHTTP(w, r)
      }
      return http.HandlerFunc(fn)
   }
}
```

panic获取并写入文件

```go
// LogPanic http panic recover
func LogPanic(next http.Handler) http.Handler {
	fn := func(w http.ResponseWriter, r *http.Request) {
		file, _ := PanicFileFromContext(r.Context())
		defer func() {
			if rvr := recover(); rvr != nil {
				// append panic info to file
				panicTimae := time.Now().Format("2006-01-02 15:04:05")
				if _, err := file.WriteString(fmt.Sprintf("\n%s: %v\n %s", panicTime, rvr, debug.Stack())); err != nil {
					fmt.Printf("write panic file error , %s", err.Error())
				}
			}
		}()

		next.ServeHTTP(w, r)
	}

	return http.HandlerFunc(fn)
}
```

说明

- 文件是通过chi的middleware注入进去
- 通过内置函数recover去获取异常信息
- 通过debug.Stack()打印异常堆栈信息