---
date :  "2019-07-30T00:19:16+08:00" 
title : "再学Linux笔记(一)文件及权限" 
categories : ["技术文章"] 
tags : ["linux"] 
toc : true
---

## 文件及权限

### 权限
- `/etc/password`：密码
- `/etc/shadow` ：个人密码
- `/etc/group`：群组

### 文件

#### rwx的含义

```
[root@e60e84b8f06d /]# ll
total 56
-rw-r--r--   1 root root 12082 Mar  5 17:36 anaconda-post.log
lrwxrwxrwx   1 root root     7 Mar  5 17:34 bin -> usr/bin
```

- rwx分为三组；第一组为当前用户root的操作权限；第二组为当前用户组的操作权限；第三组为其他用户的操作权限
- r=4，w=2，x=1；由此可以算出777，750，755，650，640等的权限含义
- 755=rwxr-xr-x； 640=rw-r-----

#### 修改群组

- chgrp: 修改group
- chmod:  修改权限
  - `chmod u/g/o/a|+/-/=|rwx`: 设置用户/用户组/其他/所有|添加/减去/设定|读写执行 权限
- chown: 修改user属主；
  - ` chown -R root:root`修改用户和用户组为root

#### 切换路径

- `cd `即 `change directory`
- `usr`即`Unix Software Resource`

#### 环境变量

1. 首先读入的是全局环境变量设置文件`/etc/profile`，然后根据其内容读取额外的文档，如`/etc/profile.d`和`/etc/inputrc`
2. 读取当前登录用户Home目录下的文件`~/.bash_profile`，其次读取`~/.bash_login`，最后读取`~/.profile`，这三个文档设定基本上是一样的，读取有优先关系
3. 读取`~/.bashrc`



`~/.profile`与`~/.bashrc`的区别:

- 这两者都具有个性化定制功能
- `~/.profile`可以设定本用户专有的路径，环境变量，等，它只能登入的时候执行一次
- `~/.bashrc`也是某用户专有设定文档，可以设定路径，命令别名，每次shell script的执行都会使用它一次