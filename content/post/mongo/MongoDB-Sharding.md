---
date :  "2018-05-24T14:25:20+08:00" 
title : "MongoDB-Sharding" 
categories : ["技术文章"] 
tags : ["mongo"] 
toc : true
---

## Sharding

sh 命令

```shell
rs0:PRIMARY> sh.help()
        sh.addShard( host )                       server:port OR setname/server:port
        sh.enableSharding(dbname)                 enables sharding on the database dbname
        sh.shardCollection(fullName,key,unique)   shards the collection
        sh.splitFind(fullName,find)               splits the chunk that find is in at the median
        sh.splitAt(fullName,middle)               splits the chunk that middle is in at middle
        sh.moveChunk(fullName,find,to)            move the chunk where 'find' is to 'to' (name of shard)
        sh.setBalancerState( <bool on or not> )   turns the balancer on or off true=on, false=off
        sh.getBalancerState()                     return true if enabled
        sh.isBalancerRunning()                    return true if the balancer has work in progress on any mongos
        sh.addShardTag(shard,tag)                 adds the tag to the shard
        sh.removeShardTag(shard,tag)              removes the tag from the shard
        sh.addTagRange(fullName,min,max,tag)      tags the specified range of the given collection
        sh.status()                               prints a general overview of the cluster
```

检查状态

```
rs0:PRIMARY> sh.status()
printShardingStatus: this db does not have sharding enabled. be sure you are connecting to a mongos from the shell and not to a mongod.
```

