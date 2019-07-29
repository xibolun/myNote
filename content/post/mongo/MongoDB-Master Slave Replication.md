---

date :  "2017-11-14T23:36:24+08:00" 
title : "MongoDB Master Slave Replication"  
tags : ["Mongo"] 
toc : true
---


## Replication--Master Slave Replication

![replica-set-read-write-operations-primary.bakedsvg](http://oxmycii3v.bkt.clouddn.com/img/mongodb/replica-set-read-write-operations-primary.bakedsvg.svg)

### Mongod命令列表

- dbpath: 指定数据库文件目录，若不存在，则提示异常

- port: 端口号指定

- master:指定主节点

- slaver:指定从节点

- source: 指定主节点来源

- autoresync: 自动同步，当主节点的oplog太老的时候，使用此参数可以自动同步

- config: 指定配置文件进行启动，配置文件里面可以添加mongo的端口号，数据库位置等

  ```properties
  dbpath=/mongodb/master
  logpath=/mongodb/log/master.log
  master=true
  # slave=true
  # source=localhost:10001
  # autoresync=true
  fork=true
  port=10001
  oplogSize=2048
  ```

##### 主节点启动

启动主节点，端口号设为10001

```shell
mongod --dbpath projects/mongodb/data/db --port 10001 --master
```

##### 从节点启动方式一：

```shell
mongod --dbpath /tmp/slave --port 10002  --slave --source localhost:10001 --autoresync

2017-11-14T15:40:02.636+0800 I NETWORK  [thread1] waiting for connections on port 100022017-11-14T15:40:03.638+0800 I REPL     [replslave] syncing from host:localhost:10001
2017-11-14T15:40:03.642+0800 I REPL     [replslave] syncing from host:localhost:100012017-11-14T15:40:04.726+0800 I REPL     [replslave] syncing from host:localhost:10001
2017-11-14T15:40:05.730+0800 I REPL     [replslave] syncing from host:localhost:100012017-11-14T15:40:06.735+0800 I REPL     [replslave] syncing from host:localhost:10001
2017-11-14T15:40:07.737+0800 I REPL     [replslave] syncing from host:localhost:100012017-11-14T15:40:09.407+0800 I REPL     [replslave] syncing from host:localhost:10001
2017-11-14T15:40:10.408+0800 I REPL     [replslave] syncing from host:localhost:10001
```

##### 从节点启动方式二：

```shell
➜  projects mongo -port 10002
> use local
switched to db local
> db.sources.insert({"host":"localhost:10001"});
WriteResult({ "nInserted" : 1 })
> db.sources.find();
{ "_id" : ObjectId("5a0a9f3a6b2b725c4a09f8be"), "host" : "localhost:10001", "source" : "main", "syncedTo" : Timestamp(1510645568, 1), "dbsNextPass" : { "hf-cmdb5" : true, "test" : true }, "incompleteCloneDbs" : { "hf-cmdb5" : true } }
> rs.slaveOk();
> show dbs;
admin     0.000GB
hf-cmdb5  0.009GB
local     0.000GB
test      0.086GB
```

###### 查看主节点同步信息

```shell
> db.printReplicationInfo();
configured oplog size:   192MB
log length start to end: 3999secs (1.11hrs)
oplog first event time:  Tue Nov 14 2017 15:10:23 GMT+0800 (CST)
oplog last event time:   Tue Nov 14 2017 16:17:02 GMT+0800 (CST)
now:                     Tue Nov 14 2017 16:17:07 GMT+0800 (CST)
```

###### 查看从节点同步信息

```shell
> db.printSlaveReplicationInfo();
source: localhost:10001
        syncedTo: Tue Nov 14 2017 16:19:42 GMT+0800 (CST)
        10 secs (0 hrs) behind the freshest member (no primary available at the moment)
```

> 2.6版本后使用rs.printSlaveReplicationInfo(); rs.printReplicationInfo();

- 若主节点突然挂掉，从节点会每3s请求一次，直到主节点起来

  ```shell
  2017-11-14T17:13:07.847+0800 W NETWORK  [replslave] Failed to connect to 127.0.0.1:10001, in(checking socket for error after poll), reason: Connection refused
  2017-11-14T17:13:07.847+0800 E REPL     [replslave] couldn't connect to server localhost:10001, connection attempt failed
  2017-11-14T17:13:07.847+0800 I REPL     [replslave] sleep 3 sec before next pass
  ```

  ​

#### 遇到问题

连接slave的时候，做查询报错，原因是默认slave不允许读写需要进行设置

```
> show dbs;
2017-11-14T15:13:26.658+0800 E QUERY    [thread1] Error: listDatabases failed:{
        "ok" : 0,
        "errmsg" : "not master and slaveOk=false",
        "code" : 13435,
        "codeName" : "NotMasterNoSlaveOk"
} :
```

```
> rs.slaveOk();
> show dbs;
admin     0.000GBhf-cmdb5  0.009GB
local     0.000GB
test      0.086GB
```

