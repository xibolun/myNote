---
date :  "2020-01-01T22:26:59+08:00" 
title : "SaltStack(附)自己遇到的一些问题" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

## Saltstack的问题

### 执行节点重复

场景: salt-key只有一个，执行结果却有三个

```shell
# salt-key -L | grep xmdb
xmdb
```

执行结果

```shell
salt xmdb test.ping
xmdb:
    True
xmdb:
    True
xmdb:
    True
```

### 能Ping通，却无返回值

需要查看一下`4505`和`4506`端口是否通，因为建立通讯是通过`4505`和`4506`来建立的

`telnet IP 4505`

### Master换了，如何快速迁移



