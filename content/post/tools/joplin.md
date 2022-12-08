---
date :  "2022-12-08 15:01:40+08:00"
title : "Joplin环境搭建" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
---

### Joplin使用

[Joplin](https://github.com/laurent22/joplin)是一个私有部署的笔记软件，它的几个特点：

- 针对于markdown友好，
- 有桌面客户端，移动端，使用起来也非常的方便；可自定义的快捷键；

- 最强大的地方在于备份，支持s3、Nextcloud, Dropbox, OneDrive、Joplin Server等，并且支持 [e2ee](https://joplinapp.org/e2ee/)加密;
- 插件生态：https://github.com/joplin/plugins
- 论坛生态：https://discourse.joplinapp.org/



### JopinServer搭建

docker-compose一键安装

docker-compose.yml文件，可参考官方的 [docker-compose.server.yml](https://github.com/laurent22/joplin/blob/dev/docker-compose.server.yml)

```yaml
version: '3'

services:
    db:
        image: postgres:13
        volumes:
            - ./data/postgres:/var/lib/postgresql/data
        ports:
            - "5432:5432"
        restart: unless-stopped
        environment:
            - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
            - POSTGRES_USER=${POSTGRES_USER}
            - POSTGRES_DB=${POSTGRES_DATABASE}
    app:
        image: joplin/server:latest
        depends_on:
            - db
        ports:
            - "22300:22300"
        restart: unless-stopped
        environment:
            - APP_PORT=22300
            - APP_BASE_URL=${APP_BASE_URL}
            - DB_CLIENT=pg
            - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
            - POSTGRES_DATABASE=${POSTGRES_DATABASE}
            - POSTGRES_USER=${POSTGRES_USER}
            - POSTGRES_PORT=${POSTGRES_PORT}
            - POSTGRES_HOST=db
```

.env文件

```
APP_BASE_URL=http://10.200.20.216:22300
APP_PORT=22300
#
DB_CLIENT=postgres
POSTGRES_PASSWORD=xxxx
POSTGRES_DATABASE=xxxxxx
POSTGRES_USER=xxxxx
POSTGRES_PORT=5432
POSTGRES_HOST=localhost
```

启动

```
docker-compose up -d 
```

访问

```
http://10.200.20.216:22300
```

默认会生成email/passowrd: 

```
admin@localhost
admin
```

修改用户名密码后将地址、用户名、密码三个变量配置至客户端同步配置当中即可

### 参考

- https://github.com/laurent22/joplin/issues/5300