---
date :  "2019-09-18T14:37:41+08:00" 
title : "Kafka(二)操作" 
categories : ["技术文章"] 
tags : ["kafka"] 
toc : true
---

### Topic

创建；topic 拥有一个分区，一个备份

```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```

创建多个分区，多个备份

```
bin/kafka-topics.sh  --zookeeper localhost:2181 --create --topic zstack --partitions 2 --replication-factor 1
```
创建好的分区与备份体现在log里面
```
# ls /tmp/kafka-logs-1| grep zstack
zstack-0
zstack-1
```

```
ls /tmp/kafka-logs | grep zstack
zstack-0
zstack-1
```

```
 ls /tmp/kafka-logs-2 | grep zstack
zstack-0
zstack-1
```

查询列表

```
bin/kafka-topics.sh --list --zookeeper localhost:2181
```

