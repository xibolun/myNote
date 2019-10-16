---

date :  "2017-11-15T23:36:24+08:00" 
title : "MongoDB ReplSet Replication"  
tags : ["Mongo"] 
toc : true
---

## ReplSet Replicatin

![replica-set-trigger-election](http://oxmycii3v.bkt.clouddn.com/img/mongodb/replica-set-trigger-election.bakedsvg.svg)

master的IP： 10.0.1.9     slave IP: 10.0.106.2、10.0.106.6

以replSet形式启动master，replSet名称设置为rs0

```shell
mongod --dbpath /home/www/data/ --replSet rs0
```

连接master，将自己做为一个member添加进去

```shell
> rs.initiate({_id:"rs0",members:[{_id:0,host:"10.0.1.9:27017"}]})
{
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
rs0:PRIMARY> 
```

初始化成功后，shell会发生改变为   rs0:PRIMARY，标志着replSet的名称和主server；

添加成员

```shell
rs0:PRIMARY> rs.add("10.0.106.2:27017")
{ "ok" : 1 }
rs0:PRIMARY> rs.add("10.0.106.6:27017")
{ "ok" : 1 }
```

此时master的日志里面会出现以下log信息，说明已经有成员连接进来

```verilog
2017-11-15T10:48:43.995+0800 [rsHealthPoll] replSet member 10.0.106.2:27017 is now in state SECONDARY
```

而slave的日志如下，开始连接master，然后并开始同步数据

```verilog
2017-11-15T10:48:27.911+0800 I NETWORK  [initandlisten] connection accepted from 10.0.1.9:54292 #1 (1 connection now open)
2017-11-15T10:48:27.913+0800 I NETWORK  [initandlisten] connection accepted from 10.0.1.9:54293 #2 (2 connections now open)
2017-11-15T10:48:27.917+0800 I ASIO     [NetworkInterfaceASIO-Replication-0] Successfully connected to 10.0.1.9:27017
2017-11-15T10:48:27.947+0800 I NETWORK  [conn1] end connection 10.0.1.9:54292 (1 connection now open)
2017-11-15T10:48:27.950+0800 I REPL     [replExecDBWorker-0] Starting replication applier threads
2017-11-15T10:48:27.950+0800 I REPL     [ReplicationExecutor] New replica set config in use: { _id: "rs0", version: 2, members: [ { _id: 0, host: "10.0.1.9:27017", arbiterOnly: false, buildIndexes: true, hidden: false, priority: 1.0, ta
gs: {}, slaveDelay: 0, votes: 1 }, { _id: 1, host: "10.0.106.2:27017", arbiterOnly: false, buildIndexes: true, hidden: false, priority: 1.0, tags: {}, slaveDelay: 0, votes: 1 } ], settings: { chainingAllowed: true, heartbeatIntervalMill
is: 2000, heartbeatTimeoutSecs: 10, electionTimeoutMillis: 10000, getLastErrorModes: {}, getLastErrorDefaults: { w: 1, wtimeout: 0 } } }
2017-11-15T10:48:27.950+0800 I REPL     [ReplicationExecutor] This node is 10.0.106.2:27017 in the config
2017-11-15T10:48:27.950+0800 I REPL     [ReplicationExecutor] transition to STARTUP2
2017-11-15T10:48:27.951+0800 I REPL     [rsSync] ******
2017-11-15T10:48:27.951+0800 I REPL     [rsSync] creating replication oplog of size: 990MB...
2017-11-15T10:48:27.952+0800 I REPL     [ReplicationExecutor] Member 10.0.1.9:27017 is now in state PRIMARY
2017-11-15T10:48:27.956+0800 I STORAGE  [rsSync] Starting WiredTigerRecordStoreThread local.oplog.rs
2017-11-15T10:48:27.957+0800 I STORAGE  [rsSync] The size storer reports that the oplog contains 0 records totaling to 0 bytes
2017-11-15T10:48:27.957+0800 I STORAGE  [rsSync] Scanning the oplog to determine where to place markers for truncation
2017-11-15T10:48:27.996+0800 I REPL     [rsSync] ******
2017-11-15T10:48:27.996+0800 I REPL     [rsSync] initial sync pending
2017-11-15T10:48:28.012+0800 I REPL     [ReplicationExecutor] syncing from: 10.0.1.9:27017
2017-11-15T10:48:28.017+0800 I REPL     [rsSync] initial sync drop all databases
2017-11-15T10:48:28.017+0800 I STORAGE  [rsSync] dropAllDatabasesExceptLocal 1
2017-11-15T10:48:28.017+0800 I REPL     [rsSync] initial sync clone all databases
```

mongo shell连接至slave的时候会发现shell变成了如下样式；标志着此server为rs0的replSet，为第二个节点

```shell
rs0:SECONDARY> 
```

查询配置信息

```shell
rs0:SECONDARY> rs.conf();
{        "_id" : "rs0",
        "version" : 11,
        "members" : [
                {
                        "_id" : 0,
                        "host" : "10.0.1.9:27017",
                        "arbiterOnly" : false,
                        "buildIndexes" : true,
                        "hidden" : false,
                        "priority" : 2,
                        "tags" : {

                        },
                        "slaveDelay" : NumberLong(0),
                        "votes" : 1
                },
                {
                        "_id" : 1,
                        "host" : "10.0.106.2:27017",
                        "arbiterOnly" : false,
                        "buildIndexes" : true,
                        "hidden" : false,                        
                        "priority" : 0.8,                       
                        "tags" : {                        
                        },                       
                        "slaveDelay" : NumberLong(0),                        
                        "votes" : 1                
                        },                
                 {
                        "_id" : 2,
                        "host" : "10.0.106.6:27017",
                        "arbiterOnly" : false,
                        "buildIndexes" : true,
                        "hidden" : false,
                        "priority" : 1,
                        "tags" : {

                        },                        
                        "slaveDelay" : NumberLong(0),                        
                        "votes" : 1                
                  }
        ],
        "settings" : {
                "chainingAllowed" : true,
                "heartbeatIntervalMillis" : 2000,
                "heartbeatTimeoutSecs" : 10,
                "electionTimeoutMillis" : 10000,
                "getLastErrorModes" : {

                },
                "getLastErrorDefaults" : {
                        "w" : 1,
                        "wtimeout" : 0
                }
        }
}
```

查看状态

```shell
rs0:SECONDARY> rs.status()
{
        "set" : "rs0",
        "date" : ISODate("2017-11-15T03:20:32.831Z"),
        "myState" : 2,
        "term" : NumberLong(-1),
        "heartbeatIntervalMillis" : NumberLong(2000),
        "members" : [
                {
                        "_id" : 0,
                        "name" : "10.0.1.9:27017",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 973,
                        "optime" : Timestamp(1510714107, 1),
                        "optimeDate" : ISODate("2017-11-15T02:48:27Z"),
                        "lastHeartbeat" : ISODate("2017-11-15T03:20:32.411Z"),
                        "lastHeartbeatRecv" : ISODate("2017-11-15T03:20:32.129Z"),
                        "pingMs" : NumberLong(0),
                        "electionTime" : Timestamp(1510715061, 1),
                        "electionDate" : ISODate("2017-11-15T03:04:21Z"),
                        "configVersion" : 2
                },
                {
                        "_id" : 1,
                        "name" : "10.0.106.2:27017",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",
                        "uptime" : 974,
                        "optime" : Timestamp(1510714107, 1),
                        "optimeDate" : ISODate("2017-11-15T02:48:27Z"),
                        "infoMessage" : "could not find member to sync from",
                        "configVersion" : 2,
                        "self" : true
                }
        ],
        "ok" : 1
}
```



### 遇到的问题

```
> rs.initiate({_id:"xmdb",members:[{_id:0,host:"10.0.1.9:27017"}]})
{
        "ok" : 0,
        "errmsg" : "local.oplog.rs is not empty on the initiating member.  cannot initiate."
}
```

原因是因为本地已经存在了 replSet的opLog，所以需要去掉，再重新initiate

```shell
> use local
switched to db local
> db.dropDatabase()
{ "dropped" : "local", "ok" : 1 }
```

再重新启动，可以考虑换一个新的replSet的名称

```shell
mongod --dbpath /home/www/data/ --replSet rs0
```

再重新初始化即可

```shell
> rs.initiate({_id:"rs0",members:[{_id:0,host:"10.0.1.9:27017"}]})
{
        "info" : "Config now saved locally.  Should come online in about a minute.",
        "ok" : 1
}
rs0:PRIMARY> 
```

或者直接强制初始化

```
rs.reconfig(config, {force: true})
```



### 设置权重

```shell
rs0:PRIMARY> cfg = rs.conf();
{
        "_id" : "rs0",
        "version" : 2,
        "members" : [
                {
                        "_id" : 0,
                        "host" : "10.0.1.9:27017"
                "uth_id" : 1,
                        "host" : "10.0.106.2:27017"
                }
        ]
}
rs0:PRIMARY> cfg.members[0].priority=2
2
rs0:PRIMARY> cfg.members[1].priority=1
1
rs0:PRIMARY> cfg.members[2].priority=1
1
rs0:PRIMARY> rs.reconfig(cfg)
```



#### 注意事项

- 权重的设置只能在Master当中

```shell
rs0:SECONDARY> rs.reconfig(cfg)
{
        "ok" : 0,
        "errmsg" : "replSetReconfig command must be sent to the current replica set primary."
}
```

- 三个副本的replSet的名称必须一致
- 只有两个副本集的时候，PRIMARY挂掉之后，SECONDARY是不会成为PRIMARY的，必须三个副本集以上，最多50个副本集，并且只允许7个可投票进行选举的成员
- priority设置为0的成员是不参与投票的
- 当PRIMARY挂掉的时候，权重高的会被设置为PRIMARY；
- 非PRIMARY的副本只允许查询，不允许其他的操作；

### 使用Springboot进行操作

查看rs设置

```shell
rs0:PRIMARY> rs.conf()
{
        "_id" : "rs0",
        "version" : 12,
        "members" : [
                {
                        "_id" : 0,
                        "host" : "10.0.1.9:27017",
                        "priority" : 2
                },
                {
                        "_id" : 1,
                        "host" : "10.0.106.2:27017",
                        "priority" : 0.8
                },
                {
                        "_id" : 2,
                        "host" : "10.0.106.6:27017",
                        "priority" : 0.5
                }
        ],
        "settings" : {
                "getLastErrorDefaults" : {
                        "w" : 1,
                        "wtimeout" : 0
                }
        }
}
```

springboot application.properties文件配置
```properties
mongo.replicaSet=mongodb://10.0.1.9:27017,10.0.106.2:27017,10.0.106.6:27017
```

PRIMARY: 10.0.1.9   SECONDARY: 10.0.106.2, 10.0.106.6

当工程启动后，实验过程和结论如下

- 关闭10.0.1.9
  - 10.0.106.2成为PRIMARY
  - 10.0.106.2与10.0.106.6都在尝试重连10.0.1.9
  - 此时应用操作正常，后台无连数据不上的问题
- 关闭10.0.106.2
  - 此时没有PRIMARY，10.0.106.6仍然是SECONDARY节点
  - 此时应用操作不正常，后台过了最大尝试重连时间后直接异常提示

```shell
org.springframework.dao.DataAccessResourceFailureException: Timed out after 30000 ms while waiting for a server that matches {serverSelectors=[ReadPreferenceServerSelector{readPreference=primary}, LatencyMinimizingServerSelector{acceptableLatencyDifference=15 ms}]}. Client view of cluster state is {type=ReplicaSet, servers=[{address=10.0.1.9:27017, type=Unknown, state=Connecting, exception={com.mongodb.MongoException$Network: Exception opening the socket}, caused by {java.net.ConnectException: Connection refused}}, {address=10.0.106.2:27017, type=ReplicaSetSecondary, averageLatency=11.9 ms, state=Connected}, {address=10.0.106.6:27017, type=Unknown, state=Connecting, exception={com.mongodb.MongoException$Network: Exception opening the socket}, caused by {java.net.ConnectException: Connection refused}}]; nested exception is com.mongodb.MongoTimeoutException: Timed out after 30000 ms while waiting for a server that matches {serverSelectors=[ReadPreferenceServerSelector{readPreference=primary}, LatencyMinimizingServerSelector{acceptableLatencyDifference=15 ms}]}. Client view of cluster state is {type=ReplicaSet, servers=[{address=10.0.1.9:27017, type=Unknown, state=Connecting, exception={com.mongodb.MongoException$Network: Exception opening the socket}, caused by {java.net.ConnectException: Connection refused}}, {address=10.0.106.2:27017, type=ReplicaSetSecondary, averageLatency=11.9 ms, state=Connected}, {address=10.0.106.6:27017, type=Unknown, state=Connecting, exception={com.mongodb.MongoException$Network: Exception opening the socket}, caused by {java.net.ConnectException: Connection refused}}]
```

- 重新启动10.0.106.2
  - 节点10.0.106.2变为PRIMARY
  - 此时应用开始恢复，正常操作
- 重新启动10.0.1.9
  - 节点10.0.106.6变为SECONDARY，10.0.1.9变为PRIMARY
  - 此时应用正常操作

- 当没有PRIMARY的时候，应用才会宕机
- 当三个节点组成replica set的时候，集群宕机到只剩下一台机器的时候，就没有PRIMARY节点，应用也就无法正常运转
- spring配置文件当中的配置顺序没有关系