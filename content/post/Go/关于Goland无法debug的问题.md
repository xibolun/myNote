---

date :  "2021-01-18T14:50:13+08:00" 
title : "M1 Goland无法debug" 
categories : ["go"] 
tags : ["go","tool"] 
toc : true
description: goland debug 
---

### 起因

新版本的m1是`ARM`架构，在安装完`2020.03`版本的`Goland`后，非`debug`启动正常，但`debug`启动的时候报错如下：

```
rosetta error: failed to allocate vm space for aot
```

在[jetbrains的讨论区看了一下](https://youtrack.jetbrains.com/issue/GO-10235)，没有什么好的解决方法，只有等`delve`修复这个bug；

在`delve`[里面看到了一些讨论](https://github.com/go-delve/delve/issues/2246)；看到了两个`PR`

- [Go 1.16 support branch ](https://github.com/go-delve/delve/commit/6dd686ca49e6da2e3fda1e0355623fed72500504)，主要解决`arm`版本和filepath的问题
- [Added support for darwin/arm64 using gdbserver](https://github.com/go-delve/delve/commit/57f033e4bcc94b6b9fee3ea93707f4a375437d78)，这个PR已经支持了ARM架构

但是官网的最新的 [v1.5.1](https://github.com/go-delve/delve/releases/tag/v1.5.1)版本比较早，这两个PR还未正式发布，所以只能自己动手编译；

### 操作

- 在 [golang download](https://golang.org/dl/#unstable) 下载go1.16beta1 arm版本，替换自己的`go`版本，升级为1.16.

```shell
➜  ~ go version
go version go1.16beta1 darwin/arm64
```

- 下载 [delve](https://github.com/go-delve/delve)源码，`master`分支，编译`make`即可在`$GOPATH/bin`下面得到一个`dlv`的文件

```shell
make install
```

- 在goland当中使用最新的`delve`进行`debug`，在`help -> Edit Custom Vm Option`添加如下配置，重启`IDE`

```shell
-Ddlv.path=/Users/admin/projects/go/bin/dlv
```

也可以直接替换

```shell
cp dlv /Applications/GoLand.app/Contents/plugins/go/lib/dlv/mac/dlv
```

### 其他异常

IDE版本可能不对；

- Goland需要使用arm版本，而使用了intel版本，会导致如下报错：https://github.com/go-delve/delve/pull/2285#issuecomment-757105998
- Go运行版本不对，比如说非arm或者老的版本等