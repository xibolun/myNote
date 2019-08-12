---
date :  "2019-07-30T22:38:08+08:00" 
title : "再学Linux笔记(二)文件与目录" 
categories : ["技术文章"] 
tags : ["linux"] 
toc : true
---

#### root目录下的两个特殊的目录

```
[root@7e02d7cc602a /]# ls -al
total 64
drwxr-xr-x   1 root root  4096 Jul 10 13:08 .
drwxr-xr-x   1 root root  4096 Jul 10 13:08 ..
```

这两个目录其实是一个目录

### 目录创建

```
## 创建指定权限的目录
mkdir -m 777 /tmp/aa 
## 递归创建目录
mdkir -p /tmp/aa
```

### 目录管理

```
## 复制的时候，保留文件和目录的权限信息
cp -a /etc /tmp 
## 有差异地复制
cp -u ~/.bashrc /tmp/.bashrc
## 创建文件带-
touch ./-aaa-
rm ./-aaa- 或 rm -- -aaa- 

```

### 文档查看

cat的缩写是：`Concatenate`

```
## -A, --show-all 显示所有的特殊字符 $ 表示换行； ^I 表示tab
[root@7e02d7cc602a tmp]# cat -A /etc/issue
## -n, --number  显示行号
[root@7e02d7cc602a tmp]# cat -n /etc/issue
[root@7e02d7cc602a tmp]# ^C
## od命令也挺有意思的
[root@7e02d7cc602a tmp]# cat aa.log 
ABC
[root@7e02d7cc602a tmp]# od -t c aa.log 
0000000   A   B   C  \n
0000004
[root@7e02d7cc602a tmp]# od aa.log 
0000000 041101 005103
0000004
[root@7e02d7cc602a tmp]# 
```

### 文档的时间

- mtime(modification time): 数据变更时间
- ctime(status time): 文档状态改变，权限属性改变
- atime(access time): 文件读取时间； cat等操作
- 以上使用可以通过touch -a

