---

date :  "2018-03-04T22:42:15+08:00" 
title : "Redis学习" 
categories : ["技术文章"] 
tags : ["redis"] 
toc : true
---

## Redis学习笔记

redis-cli del 'LOGIN~ERRORLIMIT~:zhangbo'


### Redis命令 ###

``` shell
# 查看信息
INFO

# 测试是否正常启动
PING

# 
```

#### 配置 ####

#### 设置密码 ####

``` shell
# 若设置了密码，则使用任何命令之前必须进行验证 
127.0.0.1:6379> CONFIG SET requirepass 'pengganyu'
OK

127.0.0.1:6379> AUTH 'pengganyu'
OK

127.0.0.1:6379> CONFIG GET requirepass
1) "requirepass"
2) "pengganyu"
```

### Docker ###

``` shell
# start redis container
docker run --name my-redis -v ~/projects/docker/redis/data:/data -p 6379:6379 -d redis

# add redis-cli
docker run -it --link my-redis:redis --rm redis redis-cli -h redis -p 6379
```

