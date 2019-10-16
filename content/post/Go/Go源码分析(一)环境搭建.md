---
date :  "2019-09-02T20:19:12+08:00" 
title : "Go源码分析(一)环境搭建" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

## Go源码分析(一)

### 环境搭建

#### 安装依赖

- `gcc` : 可以使用`gcc -v`查看
- `bzip2`

```shell
[root@bootos src]# ./all.bash 
# Building C bootstrap tool.
cmd/dist
./make.bash: line 132: gcc: command not found
[root@bootos src]# yum insatll gcc
```

### 下载go1.4

若想要使用go自己编译go源码（即自举），需要使用go1.4先编译一个go出来

```
curl -O -k https://dl.google.com/go/go1.4-bootstrap-20171003.tar.gz
```

解压，进入src目录先编译`go 1.4`； 若不想编译那些test，可以使用`./make.sh`进行编译

```shell
[root@bootos src]# ./all.bash 
# Building C bootstrap tool.          
cmd/dist                                       
                                                           
# Building compilers and Go bootstrap tool for host, linux/amd64.
lib9                                                   
libbio                                                 
liblink                                                
cmd/cc                                                 
cmd/gc                                         
cmd/6l                                                 
cmd/6a                                                 
cmd/6c                                                 
cmd/6g                        
runtime    
.....
# Checking API compatibility.
Skipping cmd/api checks

real    0m0.491s
user    0m0.382s
sys     0m0.077s

ALL TESTS PASSED

---
Installed Go for linux/amd64 in /home/go
Installed commands in /home/go/bin
*** You need to add /home/go/bin to your PATH.
```

设置环境变量，准备编译go源码

```shell
## source ~/.bashrc  
export PATH=$PATH:/home/go/bin
```

编译go1.12版本；你也可以下载自己想要编译的版本，或者直接clone官方的git仓库，选择对应的分支进行build

```shell
curl -O -k  https://dl.google.com/go/go1.12.9.src.tar.gz
```

解压，进入src进行编译；若不想编译那些test，可以使用`./make.sh`进行编译

```
[root@bootos src]# ./all.bash 
Building Go cmd/dist using /home/go.
Building Go toolchain1 using /home/go.
Building Go bootstrap cmd/go (go_bootstrap) using Go toolchain1.
Building Go toolchain2 using go_bootstrap and Go toolchain1.
Building Go toolchain3 using go_bootstrap and Go toolchain2.
##### API check
Go version is "go1.12.9", ignoring -next /root/go/api/next.txt

ALL TESTS PASSED
---
Installed Go for linux/amd64 in /root/go
Installed commands in /root/go/bin
*** You need to add /root/go/bin to your PATH.
```

配置环境变量，此处配置了全量的环境变量，目的是于1.4版本设置的环境变量做区分

```shell
## source ~/.bashrc  
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/go/bin
```

交叉编译一个bootstrap版本的go

```shell
[root@bootos src]# GOOS=linux GOARCH=amd64 ./bootstrap.bash
#### Copying to ../../go-linux-amd64-bootstrap

#### Cleaning ../../go-linux-amd64-bootstrap

#### Building ../../go-linux-amd64-bootstrap

Building Go cmd/dist using /home/go.
Building Go toolchain1 using /home/go.
Building Go bootstrap cmd/go (go_bootstrap) using Go toolchain1.
Building Go toolchain2 using go_bootstrap and Go toolchain1.
Building Go toolchain3 using go_bootstrap and Go toolchain2.
Building packages and commands for linux/amd64.
----
Bootstrap toolchain for linux/amd64 installed in /root/go-linux-amd64-bootstrap.
Building tbz.
-rw-r--r-- 1 root root 116210357 Apr 13 00:48 /root/go-linux-amd64-bootstrap.tbz
```

测试是否成功

```shell
[root@bootos ~]# go run hello.go 
hello, world
[root@bootos ~]# go version
go version go1.12.9 linux/amd64
```
### 说明
- 部署golang1.4早前的一些版本会存在一些问题，比如说之前最常遇到的就是format.test类里面的日期报错问题 [官方issue-19457](https://github.com/golang/go/issues/19457)
- 编译go源码可以有多种方式，gccgo也可以

### 参考

- [install source](https://golang.org/doc/install/source)
