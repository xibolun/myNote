---

date :  "2020-11-16T14:13:01+08:00" 
title : "GitBook使用Dockerfile" 
categories : ["技术文章"] 
tags : ["docker","gitbook"] 
toc : true
---

## GitBook使用Dockerfile

初始化目录

```
gitbook init
```

添加文件，编译启动

```
gitbook serve
```

编译完成后会生成`_book`目录

```shell
➜ ll _book
total 264
-rw-r--r--   1 admin  staff    22K Nov 16 13:51 Act2API文档.html
-rw-r--r--   1 admin  staff    78B Nov 16 13:51 Dockerfile
drwxr-xr-x  13 admin  staff   416B Nov 16 13:51 gitbook
-rw-r--r--   1 admin  staff   8.9K Nov 16 13:51 index.html
-rw-r--r--   1 admin  staff    73K Nov 16 13:51 search_index.json
-rw-r--r--   1 admin  staff    11K Nov 16 13:51 ssh通道执行流程.html
-rw-r--r--   1 admin  staff   931B Nov 16 13:51 主机上报原理.md
```

可以看到里面编译出来的就是`index.html`静态页面；

直接可以使用`nginx`进行构建 一个镜像

```dockerfile
FROM nginx
WORKDIR /usr/share/nginx/html
ADD _book/. /usr/share/nginx/html
EXPOSE 80
```

编译

```shell
docker build -t registry.idcos.com/cloudpower/cloud-act2-docs:v1.0 .
```

上传

```shell
docker push registry.idcos.com/cloudpower/cloud-act2-docs:v1.0
```

启动

```shell
docker run -dp 80:80 --name cloud-act2-gitbook registry.idcos.com/cloudpower/cloud-act2-docs:v1.0
```

