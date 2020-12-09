---

date :  "2017-06-02T23:36:24+08:00" 
title : "curl学习" 
categories : ["tool"] 
tags : ["curl","tool"] 
toc : true
---

CURL概述
--------

CURL(command line url viewer),是命令行工具，发出网络请求，得到并提取数据，显示在标准输出里面，支持多种协议

CURL命令
--------

-   curl -o file url: 保存url的网页
-   curl -C -o url: 断点下载文件
-   curl -L url: 跳转至某个页面
-   curl -k : 关闭https的证书认证
-   curl -i url: 显示url的头部信息
-   curl -v url: 显示请求的通信过程

body请求
--------

- curl -X POST --data "data=xxx" url: 将参数信息放到--data里面 或-d

- curl url?data=xxx : get请求直接在后面拼装参数即可，curl默认是get请求

- `curl -X POST --data "@/tmp/collection.txt" http://xxxx`  请求数据以文件形式进行传递

- curl -u username:password url: http认证

- curl -u username url: 输入用户后再提示输入密码，为了安全

-   curl -u username:password -T file <ftp://ftpserver.com>:
    上传文件到ftp
    
    > curl请求默认是非application/json，所以需要添加 `-H 'Content-Type: application/json'`

添加cookie
----------

``` shell
curl --cookie "access-token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTY0NTgwMzcsImxvZ2luTmFtZSI6ImFkbWluIiwibmFtZUNOIjoi57O757uf566h55CG5ZGYIiwidGltZW91dCI6MjQsInVzZXJJZCI6IjU3M2E0Njk4ZTRiMGQ5MDY2OGJjOWYwMyIsInVzZXJOYW1lIjoiYWRtaW4ifQ.DuWu64q_xiTHJFxQ8X9nMlGwFo82UtP_-2axvKgWois"  http://10.0.106.37:8080/app/backop/6b9ab697-4f81-42e8-8a98-80b1e3f6f0a7/syncmdb
```

#### websocket请求

```shell
curl --include \
     --no-buffer \
     --header "Connection: Upgrade" \
     --header "Upgrade: websocket" \
     --header "Host: 10.0.2.1:8086" \
     --header "Origin: http://10.0.2.1:8086" \
     --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
     --header "Sec-WebSocket-Version: 13" \
     http://10.0.2.1:8086/ws/unread
```

