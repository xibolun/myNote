---
date :  "2019-09-06T07:59:20+08:00" 
title : "Go源码分析(二)Debug工具" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true
---

## Go源码分析(二)Debug工具

### gdb

- 什么是GDB，[GDB](https://www.gnu.org/software/gdb/)官网给出了详细的介绍，下载，以及bug，git地址等
- 为什么要用它？当你想debug，不知道源代码到底是什么东西的时候，因为只有一个二进制程序；若有太多的goroutine，你根本分不清到底这些里面是什么鬼的时候
- 如何使用，[Golang官网](https://golang.org/doc/gdb)给出了一份教程

#### 命令参数

- [GDB调试利器](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/gdb.html)

#### 实战

写一份代码`main.go`

```go
package main

import "fmt"

func main() {
	for i := 0; i < 10; i++ {
		fmt.Printf("current number is %d", i)
	}
}
```

编译，依赖`GOPATH` 设置

```shell
go build -gcflags "-N -l"  -o main main.go
```

开始`GDB`

```shell
[root@bootos src]# gdb main                                                    
GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-114.el7                           
Copyright (C) 2013 Free Software Foundation, Inc.                              
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.             
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"     
and "show warranty" for details.                                               
This GDB was configured as "x86_64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /home/work/go/src/main...done.
Loading Go Runtime support.
(gdb) 
```

```shell
(gdb) list
1       package main
2
3       import "fmt"
4       func main() {
5               for i := 0; i < 10; i++ {
6                       fmt.Printf("current number is %d\n", i)
7               }
8       }
```
给第6行添加断点
```shell
(gdb) b 6
Breakpoint 1 at 0x488b27: file /home/work/go/src/main.go, line 6.
```
查看断点；删除断点`delete 1`

```shell
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000488b27 in main.main at /home/work/go/src/main.go:6
```

开始运行

```shell
(gdb) run 
Starting program: /home/work/go/src/main 

Breakpoint 1, main.main () at /home/work/go/src/main.go:6
6                       fmt.Printf("current number is %d\n", i)
```
查看i的value
```shell
(gdb) p i
$1 = 0
```
i是什么类型的？
```shell
(gdb) whatis i
type = int
```

```shell
(gdb) info i
  Num  Description       Executable        
* 1    process 35320     /home/work/go/src/main 
```

进入函数 `fmt.Printf`

```shell
(gdb) s
fmt.Printf (format="current number is %d\n", a= []interface {} = {...}, n=<optimized out>, err=...) at /root/go/src/fmt/print.go:207
warning: Source file is more recent than executable.
207     func Printf(format string, a ...interface{}) (n int, err error) {
```

查看代码

```shell
(gdb) l
202             return
203     }
204
205     // Printf formats according to a format specifier and writes to standard output.
206     // It returns the number of bytes written and any write error encountered.
207     func Printf(format string, a ...interface{}) (n int, err error) {
208             return Fprintf(os.Stdout, format, a...)
209     }
210
211     // Sprintf formats according to a format specifier and returns the resulting string.
```

打印参数

```shell
(gdb) info args
format = "current number is %d\n"
a =  []interface {} = {{_type = 0x498c60, data = 0x15}}
n = <optimized out>
err = <optimized out>
```

返回上一层

```shell
(gdb) return
Make fmt.Printf return now? (y or n) y
#0  0x0000000000488bb9 in main.main () at /home/work/go/src/main.go:6
6                       fmt.Printf("current number is %d\n", i)
```

查看当前的goroutines

```shell
(gdb) info goroutines 
* 1 running  syscall.Syscall
  2 waiting  runtime.gopark
  3 waiting  runtime.gopark
  17 waiting  runtime.gopark
```

命令行页面操作的太麻烦了，不够直观，可以使用[layout模式](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/gdb.html#id9)

```shell
   ┌──/home/work/go/src/main.go──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
   │1       package main                                                                                                                                     │
   │2                                                                                                                                                        │
   │3       import "fmt"                                                                                                                                     │
   │4       func main() {                                                                                                                                    │
   │5               for i := 0; i < 10; i++ {                                                                                                                │
   │6                       fmt.Printf("current number is %d\n", i)                                                                                          │
   │7               }                                                                                                                                        │
   │8       }                                                                                                                                                
   └─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
exec No process In:                                                                                                                         Line: ??   PC: ?? 
warning: Invalid layout specified.
Usage: layout prev | next | <layout_name>

(gdb)  
```

### cgdb

[cgdb](https://cgdb.github.io/)是gdb的增强版本，若会用gdb和vi，则操作起来更加方便，官方也提供了文件说明。

安装

```shell
yum install http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/c/cgdb-0.6.8-1.el7.x86_64.rpm  -y
```

### Delve

- [Devle](https://github.com/derekparker/delve) 是golang官网提到的一个debug工具，与gdb相比，更好地能够适应golang的runtime机制；

