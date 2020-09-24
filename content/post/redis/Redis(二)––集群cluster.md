---
date :  "2020-02-27T19:49:47+08:00" 
title : "Redis(二)––集群cluster" 
categories : ["技术文章"] 
tags : ["redis"] 
toc : true
---



### Failover验证

在Redis[官网里面有一个有意思的验证方式](https://redis.io/topics/cluster-tutorial#a-more-interesting-example-application)，使用 [redis-rb-cluster](https://github.com/antirez/redis-rb-cluster)

```
git clone git@github.com:antirez/redis-rb-cluster.git
```

安装一下`ruby`环境，若`ruby`版本过低，[可能需要升级一下](https://linuxize.com/post/how-to-install-ruby-on-centos-7/)

```
yum install ruby -y
```

```
## 安装一下redis-rb-cluster当中的依赖
gem install redis
```

执行脚本，这个脚本就会一直跑着，模拟着外面的系统进行写和读的操作

```
# ruby consistency-test.rb 127.0.0.1 7000
715 R (0 err) | 715 W (0 err) |
```

此时将`7001`，`7002`进行`crash`操作，相当于将两个`master`宕机掉，端口和进程都不再存在；

```
./redis-cli -p 7001 debug segfault
./redis-cli -p 7002 debug segfault
```

可以看到会有一些读和写的error，等过一会儿等到`cluster`恢复重建后，读写恢复正常；此进也会对`slot`进行重新分配

```
Writing: Too many Cluster redirections? (last error: MOVED 7854 127.0.0.1:7001)
225032 R (16 err) | 225032 W (16 err) |
Reading: Too many Cluster redirections? (last error: MOVED 6178 127.0.0.1:7001)
Writing: Too many Cluster redirections? (last error: MOVED 6178 127.0.0.1:7001)
225036 R (17 err) | 225036 W (17 err) |
Reading: CLUSTERDOWN The cluster is down
Writing: CLUSTERDOWN The cluster is down
Writing: CLUSTERDOWN The cluster is down
225036 R (1192 err) | 225036 W (1192 err) |
Reading: CLUSTERDOWN The cluster is down
228105 R (1351 err) | 228105 W (1351 err) |
```

对比一下之前的`cluster`

| 前                                                           | 后                                                           |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 7000(master) –– 7003(slave)<br />7001(master) –– 7004(slave)<br />7002(master) –– 7005(slave) | 7000(master) –– 7003(slave)<br />7001(master,fail)<br />7002(master,fail) <br />7004(master)<br />7005(master) |

启动`7001`，`7002`后的对比，此进也会对`slot`进行重新分配；

| 前                                                           | 后                                                           |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 7000(master) –– 7003(slave)<br />7001(master) –– 7004(slave)<br />7002(master) –– 7005(slave) | 7000(master)––7003(slave)<br />7005(master)––7002(slave)<br />7004(master)––7001(slave) |

### 新加一个节点

```shell
cd /usr/local/redis/cluster-test & mkdir 7006
touch ./7006/redis_7006.conf && sed -i 's/7000/7006/g' redis.conf && cat redis.conf > 7006/redis_7006.conf
./redis-server /usr/local/redis/cluster-test/7006/redis_7006.conf
```

添加之前请清理备份文件和数据库内容

```
rm -rf /usr/local/redis/cluster-test/data/*
127.0.0.1:7000> FLUSHDB
OK
```

两种方式添加，

```
redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000 --cluster-slave
redis-cli --cluster add-node 127.0.0.1:7006 127.0.0.1:7000 --cluster-slave --cluster-master-id {master_id}
```

添加完成之后，可以看到`7006`被置为`slave`，挂在了`7005`下面

```
127.0.0.1:7000> CLUSTER NODES
c1231ec1bb8764128a1f19cfda9f473b737f5b6a 127.0.0.1:7001@17001 slave 9d8cc17f66717fc2112b23c32455072ee75afb9c 0 1582730685000 8 connected
9d8cc17f66717fc2112b23c32455072ee75afb9c 127.0.0.1:7004@17004 master - 0 1582730686522 8 connected 5461-10922
0009f3817e248c0f22d20e5ed0d2757c0b946867 127.0.0.1:7000@17000 myself,master - 0 1582730683000 1 connected 0-5460
cc39143f8f704b3eb6679317ea3798c9c981e4de 127.0.0.1:7006@17006 slave 7a2ad8bc0369e3394fb48b977d9a597b33f566e6 0 1582730682315 7 connected
e0cd923405daa6423d94d7a4e15f3dd7da8559cc 127.0.0.1:7003@17003 slave 0009f3817e248c0f22d20e5ed0d2757c0b946867 0 1582730683000 4 connected
5d97fcd2e63c294b047502ebe0759af13b3b76a5 127.0.0.1:7002@17002 slave 7a2ad8bc0369e3394fb48b977d9a597b33f566e6 0 1582730685000 7 connected
7a2ad8bc0369e3394fb48b977d9a597b33f566e6 127.0.0.1:7005@17005 master - 0 1582730685519 7 connected 10923-16383
```

删除节点

```
./redis-cli --cluster del-node 127.0.0.1:7000 cc39143f8f704b3eb6679317ea3798c9c981e4de
```

### Segfault



同时删除`master`和`slave`可以看到此时其他的四个节点不会发生变换，因为`slot`信息未做改变

```
127.0.0.1:7000> cluster nodes
c1231ec1bb8764128a1f19cfda9f473b737f5b6a 127.0.0.1:7001@17001 slave 9d8cc17f66717fc2112b23c32455072ee75afb9c 0 1583226378247 8 connected
9d8cc17f66717fc2112b23c32455072ee75afb9c 127.0.0.1:7004@17004 master - 0 1583226374000 8 connected 5461-10922
0009f3817e248c0f22d20e5ed0d2757c0b946867 127.0.0.1:7000@17000 myself,master - 0 1583226376000 1 connected 0-5460
e0cd923405daa6423d94d7a4e15f3dd7da8559cc 127.0.0.1:7003@17003 slave 0009f3817e248c0f22d20e5ed0d2757c0b946867 0 1583226377000 4 connected
5d97fcd2e63c294b047502ebe0759af13b3b76a5 127.0.0.1:7002@17002 slave,fail 7a2ad8bc0369e3394fb48b977d9a597b33f566e6 1583226342139 1583226341136 11 disconnected
7a2ad8bc0369e3394fb48b977d9a597b33f566e6 127.0.0.1:7005@17005 master,fail - 1583226362223 1583226359179 11 disconnected 10923-16383
```

这个时候，若先起动`7002 slave`，不会进行切换，`master`还是`down`的状态

```
127.0.0.1:7000> cluster nodes
c1231ec1bb8764128a1f19cfda9f473b737f5b6a 127.0.0.1:7001@17001 slave 9d8cc17f66717fc2112b23c32455072ee75afb9c 0 1583227221429 8 connected
9d8cc17f66717fc2112b23c32455072ee75afb9c 127.0.0.1:7004@17004 master - 0 1583227220428 8 connected 5461-10922
0009f3817e248c0f22d20e5ed0d2757c0b946867 127.0.0.1:7000@17000 myself,master - 0 1583227221000 1 connected 0-5460
e0cd923405daa6423d94d7a4e15f3dd7da8559cc 127.0.0.1:7003@17003 slave 0009f3817e248c0f22d20e5ed0d2757c0b946867 0 1583227222432 4 connected
5d97fcd2e63c294b047502ebe0759af13b3b76a5 127.0.0.1:7002@17002 slave 7a2ad8bc0369e3394fb48b977d9a597b33f566e6 0 1583227221000 11 connected
7a2ad8bc0369e3394fb48b977d9a597b33f566e6 127.0.0.1:7005@17005 master,fail - 1583226362223 1583226359179 11 disconnected 10923-16383
```

