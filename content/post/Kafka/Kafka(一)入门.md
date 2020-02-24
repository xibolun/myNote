---
date :  "2019-07-30T00:20:07+08:00" 
title : "Kafka(一)环境搭建及问题整理" 
categories : ["技术文章"] 
tags : ["kafka"] 
toc : true
---

### 环境搭建

### 集群

```shell
Topic:cloudboot PartitionCount:1        ReplicationFactor:3     Configs:
        Topic: cloudboot        Partition: 0    Leader: 1       Replicas: 1,2,0 Isr: 1,2,0
```



### 问题

- Kafka的消费流转模型是怎么样的？
- 新连接上来的消费者的offset是怎么样的呢？难道将每一个partition里面的消息都再次消费一遍么？
  - 目前看来是会再消费一次的，如果没有添加offset的话
- 数据量太多的时候，会报错; 需要修改参数信息`socket.request.max.bytes=10240`
- `consumer` 启动的时候指定`zk:2181`与`broker:9092 or broker:9093`有什么区别？
- `broker`模式下停掉`9092`端口好像无法再接收到消息？
- `broker`模式下宕掉非`9092`的端口其他的接收是怎么样的？
- kafka节点之间如何复制备份的？
- kafka消息是否会丢失？为什么？
- kafka最合理的配置是什么？
- kafka的leader选举机制是什么？
- kafka对硬件的配置有什么要求？
- kafka的消息保证有几种方式？
- kafka为什么会丢消息？

```shell
org.apache.kafka.common.network.InvalidReceiveException: Invalid receive (size = 100235 larger than 10240)
        at org.apache.kafka.common.network.NetworkReceive.readFromReadableChannel(NetworkReceive.java:95)
        at org.apache.kafka.common.network.NetworkReceive.readFrom(NetworkReceive.java:75)
        at org.apache.kafka.common.network.KafkaChannel.receive(KafkaChannel.java:203)
        at org.apache.kafka.common.network.KafkaChannel.read(KafkaChannel.java:167)
        at org.apache.kafka.common.network.Selector.pollSelectionKeys(Selector.java:390)
        at org.apache.kafka.common.network.Selector.poll(Selector.java:334)
        at kafka.network.Processor.poll(SocketServer.scala:500)
        at kafka.network.Processor.run(SocketServer.scala:435)
        at java.lang.Thread.run(Thread.java:745)
```



####  Partition

- message会存放在Partition当中

- 存放的位置在`server.properties`当中配置`log.dirs=/tmp/kafka-logs`

  - ```
    -rw-r--r-- 1 root root    0 Jul 23 00:08 cleaner-offset-checkpoint
    drwxr-xr-x 2 root root  141 Jul 25 14:27 __consumer_offsets-0
    -rw-r--r-- 1 root root    4 Jul 25 14:43 log-start-offset-checkpoint
    -rw-r--r-- 1 root root   54 Jul 23 00:08 meta.properties
    -rw-r--r-- 1 root root 1204 Jul 25 14:43 recovery-point-offset-checkpoint
    -rw-r--r-- 1 root root 1207 Jul 25 14:43 replication-offset-checkpoint
    drwxr-xr-x 2 root root  141 Jul 25 14:30 test-0
    ```

- 存放的格式
  
  -  offset.log `00000000000000000000.log`，即当前Partition0当中的名称为test的topic的第一条信息

