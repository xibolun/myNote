---
date :  "2017-09-20T13:07:24+08:00" 
title : "MongoDB基础学习" 
categories : ["技术文章"] 
tags : ["Mongo"] 
toc : true
---

### 安装

[各系统安装文档入口](https://docs.mongodb.com/manual/administration/install-community/)

Linux平台，添加mongo.repo

`touch /etc/yum.repos.d/mongodb-org-4.2.repo`

```shell
[mongodb-org]
name=MongoDB Repository
baseurl=http://mirrors.aliyun.com/mongodb/yum/redhat/7Server/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1
```

安装

```shell
yum install mongodb-org
....
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package mongodb-org.x86_64 0:4.2.2-1.el7 will be installed
--> Processing Dependency: mongodb-org-tools = 4.2.2 for package: mongodb-org-4.2.2-1.el7.x86_64
--> Processing Dependency: mongodb-org-shell = 4.2.2 for package: mongodb-org-4.2.2-1.el7.x86_64
--> Processing Dependency: mongodb-org-server = 4.2.2 for package: mongodb-org-4.2.2-1.el7.x86_64
--> Processing Dependency: mongodb-org-mongos = 4.2.2 for package: mongodb-org-4.2.2-1.el7.x86_64
--> Running transaction check
---> Package mongodb-org-mongos.x86_64 0:4.2.2-1.el7 will be installed
---> Package mongodb-org-server.x86_64 0:4.2.2-1.el7 will be installed
---> Package mongodb-org-shell.x86_64 0:4.2.2-1.el7 will be installed
---> Package mongodb-org-tools.x86_64 0:4.2.2-1.el7 will be installed
.....
```

启动

```shell
systemctl start mongod.service
```

### 目录说明

日志目录

```
/var/log/mongodb
```

日志文件里面记录着：版本号、git commit号、OpenSSL版本、加载模块、options、加载索引、端口号、诊断文件

数据目录

```
/var/lib/mongo/
```

