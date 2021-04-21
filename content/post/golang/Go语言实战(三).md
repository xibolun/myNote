---
date :  "2019-05-09T22:35:59+08:00" 
title : "Go语言实战(三)工具包" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true

---

### Init函数 

在操作mysql数据库的时候需要引入

```
	_ "github.com/go-sql-driver/mysql"
```

具体是引入了什么呢？引入的是`github.com/go-sql-driver/mysql/driver.go`文件里面的这个函数；只需要引入这个包里面的Init函数，而不需要使用其他的函数

```go
func init() {
	sql.Register("mysql", &MySQLDriver{})
}
```

### 工具包

#### go fmt

用于fmt代码，可以配置到不同的IDE里面进行使用

#### go doc

命令行文档帮助

```shell
go doc tar
```

基本自己的GOPATH，生成一个在线的http文档

```shell
 godoc -http=:6060
```



需要有一些注释约定

```shell
// : 函数、结构体、常量等需要export的注释
package注释
/**
*
/
```

> godoc 在1.13.x版本里面已经被废弃 

#### go build

如何在build的时候添加版本和git commit信息

```shell
go build -ldflags "-X 'idcos.io/wgen/cmd.GitBranch=`git branch | grep \* | cut -d ' ' -f2`'
-X 'idcos.io/wgen/cmd.Commit=`git rev-parse HEAD`'
-X 'idcos.io/wgen/cmd.Date=`date +'%Y-%m-%dT%H:%M:%m+08:00'`' \
-X 'idcos.io/wgen/cmd.GoVersion=`go version`'"
```

#### go get

下载指定版本的仓库

```shell
 go get <path-to-repo>@<branch>
```

