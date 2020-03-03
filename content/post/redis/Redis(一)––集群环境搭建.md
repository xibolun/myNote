---
date :  "2020-02-25T19:49:47+08:00" 
title : "Redis(一)––集群环境搭建" 
categories : ["技术文章"] 
tags : ["redis"] 
toc : true
---

### 高可用模式

- 单机：基本上是自己学习使用，生产上应该没有人用单机版本的
- 主从：可以做到读写分享，但不是最优的高可用架构；
- [哨兵](https://redis.io/topics/sentinel)：官方提供的高可用解决方案
- [集群](https://redis.io/topics/cluster-spec#redis-cluster-specification)：现在大部分使用的高可用解决方案；

### 单机部署

```
$ wget http://download.redis.io/releases/redis-5.0.7.tar.gz
$ tar xzf redis-5.0.7.tar.gz
$ cd redis-5.0.7
$ make

// start 
$ src/redis-server

// client connection
$ src/redis-cli
redis> set foo bar
OK
redis> get foo
"bar"
```

> make的时候需要依赖gcc；使用yum install -y gcc即可

[在线版本](http://try.redis.io/)



起动的log

```
99286:C 25 Feb 2020 20:20:24.008 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
99286:C 25 Feb 2020 20:20:24.008 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=99286, just started
99286:C 25 Feb 2020 20:20:24.008 # Warning: no config file specified, using the default config. In order to specify a config file use ./src/redis-server /path/to/redis.conf
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 5.0.7 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 99286
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

99286:M 25 Feb 2020 20:20:24.009 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
99286:M 25 Feb 2020 20:20:24.009 # Server initialized
99286:M 25 Feb 2020 20:20:24.009 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
99286:M 25 Feb 2020 20:20:24.009 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
99286:M 25 Feb 2020 20:20:24.009 * Ready to accept connections
```

从起动log里面可以看出的一些东西

- 版本&进程：`Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=99286, just started`
- 配置文件：` ./src/redis-server /path/to/redis.conf`
- 模式(默认单机模式)：`Running in standalone mode`
- 端口号：`Port: 6379`

### [集群环境](https://redis.io/topics/cluster-tutorial)

设置目录

- 集群目录：

```
mkdir cluster-test
cd cluster-test
mkdir 7000 7001 7002 7003 7004 7005
```

```
/usr/local/redis/cluster-test/
├── 7000
│   └── redis_7000.conf
├── 7001
│   └── redis_7001.conf
├── 7002
│   └── redis_7002.conf
├── 7003
│   └── redis_7003.conf
├── 7004
│   └── redis_7004.conf
├── 7005
│   └── redis_7005.conf
├── data
└── redis.conf
```

配置文件

```
 cat >> redis.conf << EOF
## 端口号
port 7000
## 开启集群模式
cluster-enabled yes
## 集群的配置文件，主要存在node的id等信息
cluster-config-file /usr/local/redis/cluster-test/7000/nodes.conf
## 超时时间
cluster-node-timeout 5000
## 启用追加的同步至磁盘方案
appendonly yes
## 设置后台启动
daemonize yes
## 日志路径
logfile /var/log/redis/redis_7000.log
## 数据dump的目录，也可以自己每一个节点建一套
dir /usr/local/redis/cluster-test/data
EOF
```

```
touch ./7000/redis_7000.conf && sed -i 's/7000/7000/g' redis.conf && cat redis.conf > 7000/redis_7000.conf
touch ./7001/redis_7001.conf && sed -i 's/7000/7001/g' redis.conf && cat redis.conf > 7001/redis_7001.conf
touch ./7002/redis_7002.conf && sed -i 's/7001/7002/g' redis.conf && cat redis.conf > 7002/redis_7002.conf
touch ./7003/redis_7003.conf && sed -i 's/7002/7003/g' redis.conf && cat redis.conf > 7003/redis_7003.conf
touch ./7004/redis_7004.conf && sed -i 's/7003/7004/g' redis.conf && cat redis.conf > 7004/redis_7004.conf
touch ./7005/redis_7005.conf && sed -i 's/7004/7005/g' redis.conf && cat redis.conf > 7005/redis_7005.conf
```

启动

```
./redis-server /usr/local/redis/cluster-test/7000/redis_7000.conf
./redis-server /usr/local/redis/cluster-test/7001/redis_7001.conf
./redis-server /usr/local/redis/cluster-test/7002/redis_7002.conf
./redis-server /usr/local/redis/cluster-test/7003/redis_7003.conf
./redis-server /usr/local/redis/cluster-test/7004/redis_7004.conf
./redis-server /usr/local/redis/cluster-test/7005/redis_7005.conf
```

启动日志

`cat /var/log/redis/redis_7001.log `，可以看到集群ID；

```shell
88892:C 26 Feb 2020 18:08:44.405 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
88892:C 26 Feb 2020 18:08:44.405 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=88892, just started
88892:C 26 Feb 2020 18:08:44.405 # Configuration loaded
88893:M 26 Feb 2020 18:08:44.406 * No cluster configuration found, I'm c1231ec1bb8764128a1f19cfda9f473b737f5b6a
88893:M 26 Feb 2020 18:08:44.411 * Running mode=cluster, port=7001.
88893:M 26 Feb 2020 18:08:44.411 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
88893:M 26 Feb 2020 18:08:44.411 # Server initialized
88893:M 26 Feb 2020 18:08:44.411 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
88893:M 26 Feb 2020 18:08:44.411 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
88893:M 26 Feb 2020 18:08:44.411 * Ready to accept connections
```

#### 创建集群

> To create your cluster for Redis 5 with `redis-cli` simply type:
>
> ```
> redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 \
> 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \
> --cluster-replicas 1
> ```
>
> Using `redis-trib.rb` for Redis 4 or 3 type:
>
> ```
> ./redis-trib.rb create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 \
> 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
> ```

```shell
# ./redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 --cluster-replicas 1
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 127.0.0.1:7004 to 127.0.0.1:7000
Adding replica 127.0.0.1:7005 to 127.0.0.1:7001
Adding replica 127.0.0.1:7003 to 127.0.0.1:7002
......
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
....
>>> Performing Cluster Check (using node 127.0.0.1:7000)
M: 0009f3817e248c0f22d20e5ed0d2757c0b946867 127.0.0.1:7000
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: c1231ec1bb8764128a1f19cfda9f473b737f5b6a 127.0.0.1:7001
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 9d8cc17f66717fc2112b23c32455072ee75afb9c 127.0.0.1:7004
   slots: (0 slots) slave
   replicates c1231ec1bb8764128a1f19cfda9f473b737f5b6a
S: e0cd923405daa6423d94d7a4e15f3dd7da8559cc 127.0.0.1:7003
   slots: (0 slots) slave
   replicates 0009f3817e248c0f22d20e5ed0d2757c0b946867
M: 5d97fcd2e63c294b047502ebe0759af13b3b76a5 127.0.0.1:7002
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 7a2ad8bc0369e3394fb48b977d9a597b33f566e6 127.0.0.1:7005
   slots: (0 slots) slave
   replicates 5d97fcd2e63c294b047502ebe0759af13b3b76a5
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

上面可以看到`16384`个槽位已经自动分配好了；关于`slot`的解释

> Redis Cluster does not use consistent hashing, but a different form of sharding where every key is conceptually part of what we call an **hash slot**.
>
> There are 16384 hash slots in Redis Cluster, and to compute what is the hash slot of a given key, we simply take the CRC16 of the key modulo 16384.
>
> Every node in a Redis Cluster is responsible for a subset of the hash slots, so for example you may have a cluster with 3 nodes, where:
>
> - Node A contains hash slots from 0 to 5500.
> - Node B contains hash slots from 5501 to 11000.
> - Node C contains hash slots from 11001 to 16383.
>
> This allows to add and remove nodes in the cluster easily. For example if I want to add a new node D, I need to move some hash slot from nodes A, B, C to D. Similarly if I want to remove node A from the cluster I can just move the hash slots served by A to B and C. When the node A will be empty I can remove it from the cluster completely.

此时3个master、3个slave的单机集群环境已经搭建完成，后面可以开始验证。

连接

```
./redis-cli -h 127.0.0.1 -p 7000
```

```shell
127.0.0.1:7000> cluster nodes
c1231ec1bb8764128a1f19cfda9f473b737f5b6a 127.0.0.1:7001@17001 master - 0 1582712625000 2 connected 5461-10922
9d8cc17f66717fc2112b23c32455072ee75afb9c 127.0.0.1:7004@17004 slave c1231ec1bb8764128a1f19cfda9f473b737f5b6a 0 1582712624709 5 connected
0009f3817e248c0f22d20e5ed0d2757c0b946867 127.0.0.1:7000@17000 myself,master - 0 1582712622000 1 connected 0-5460
e0cd923405daa6423d94d7a4e15f3dd7da8559cc 127.0.0.1:7003@17003 slave 0009f3817e248c0f22d20e5ed0d2757c0b946867 0 1582712625711 4 connected
5d97fcd2e63c294b047502ebe0759af13b3b76a5 127.0.0.1:7002@17002 master - 0 1582712625000 3 connected 10923-16383
7a2ad8bc0369e3394fb48b977d9a597b33f566e6 127.0.0.1:7005@17005 slave 5d97fcd2e63c294b047502ebe0759af13b3b76a5 0 1582712625000 6 connected
```

`redis`提供了`myself`的特性，这个感觉真的非常友好；

```
127.0.0.1:7000> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:614
cluster_stats_messages_pong_sent:638
cluster_stats_messages_sent:1252
cluster_stats_messages_ping_received:633
cluster_stats_messages_pong_received:614
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:1252
```

连接验证

```
./redis-cli -c -p 7000
```

```
127.0.0.1:7002> set ruby-version 2.5.1
-> Redirected to slot [2855] located at 127.0.0.1:7000
OK
```

```
./redis-cli  -c -p 7003
```

```
127.0.0.1:7003> get ruby-version
-> Redirected to slot [2855] located at 127.0.0.1:7000
"2.5.1"
```

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

