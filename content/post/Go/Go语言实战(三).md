---
date :  "2019-07-31T19:33:39+08:00" 
title : "GO语言实战(三)" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### Init函数 

在操作mysql数据库的时候需要引入

```
	_ "github.com/go-sql-driver/mysql"
```

具体是引入了什么呢？引入的是`github.com/go-sql-driver/mysql/driver.go`文件里面的这个函数；只需要引入这个包里面的Init函数，而不需要使用其他的函数

```
func init() {
	sql.Register("mysql", &MySQLDriver{})
}
```

### 工具包

#### go fmt

用于fmt代码，可以配置到不同的IDE里面进行使用

#### go doc

命令行文档帮助

```
go doc tar
```

#### godoc

基本自己的GOPATH，生成一个在线的http文档

```
 godoc -http=:6060
```

需要有一些注释约定

```
// : 函数、结构体、常量等需要export的注释
package注释
/**
*
/
```

