---

date :  "2017-09-27T13:07:24+08:00" 
title : "MongoDB基础学习" 
categories : ["技术文章"] 
tags : ["Mongo"] 
toc : true
---


启动
----

``` {.shell}
mongodump -h localhost --username dbuser --password dbuser -o
/tmp/mongodb-directory -d directory\_db\_dev mongorestore -d
hf-cmdb0622-1 --drop
--dir=/root/mongodb\_production-backup-file.201701192300/hf-cmdb/ mongo
--username dbuser --password dbuser
```

基本命令
--------

-   启动mongodb ： mongod --dbpath
    /Users/admin/projects/mongodb/data/db\
-   连接mongodb : mongo

数据类型
--------

-   String
-   Integer
-   Boolean
-   Double
-   keys
-   Arrays
-   Timestamp
-   Object
-   Null
-   Symbol
-   Date
-   Object ID
-   Binary Data
-   Code
-   Regular expression

命令介绍
--------

`mongo shell`是mongodb的命令行界面，使用`mongo`即启动成功，`quiet`参数可以忽略掉启动时输出的一些信息

```
# mongo --quiet
>
```

-   `show dbs`: 列出数据库列表
-   `use local`: 切换数据库，若不存在，默认创建一个
-   `db`: 查看当前的数据库
-   `db.test.insert({"name":"zhangsan"}):`
    插入数据，其中test为数据库的库名
-   `db.dropDatabase()`: 删除当前的数据库
-   `db.createCollection("pengganyu",{capped:true,size:1000})`: 创建固定大小的集合
-   `db.pengganyu.drop()`: 删除集合
-   `db.pengganyu.insert({title:"name"})`: 集合当中插入文档

#### 重命名一个库

```
> db.copy("old","new","localhost")
> use old;
> db.dropDatabase();
```

### 查询相关

-   在语句的结尾添加.pretty()可以格式化json
-   `show collections`： 查看所有的集合
-   db.pengganyu.find();  // 查看文档
-   db.cms~ci~.find().count(); //统计数量
-   db.getCollection('cms\_ci\_class').find({'displayName':'数据库服务节点','name':'BpDatabaseServiceRef'})；//and查询方式
-   db.getCollection('cms~ci~').find({},{"~id~":0,"source":1});//返回指定的列，0为不显示，1为显示
-   db.getCollection('cms\_ci\_class').find({'name':'BpAppModel','name':'BpDatabaseServiceRef'}); // 若两个key相同，则and查询会按照最后一个value进行查询
-   db.getCollection('cms\_ci\_class').find( {\$or:
    [{'name':'BpAppModel'},{'name':'BpDatabaseServiceRef'}\]}); //or的查询，因为or查询后面肯定是一个列表，所以是\[\]的形式
-   db.getCollection('cms\_ci\_class').find({'displayName':'数据库服务节点'},{\$or:[{'name':'BpAppModel'},{'name':'BpDatabaseServiceRef'}\]}); //and和or的联合查询
-   db.getCollection('cms_ci').find({'domain':{$nin:['hangzhou']}}).count();   //not in 查询
-   db.getCollection('cms_ci').find({'domain':{$in:['hangzhou']}}).count();  // in 查询
-   db.getCollection('cms\_ci\_class').find({'status':{\$gte:0}});  //gte:&gt;= ; lte: &lt;=
-   db.getCollection('cms\_ci\_class').find({'status':{\$gt:0}}); //gt: &gt; ; lt: &lt;
-   db.getCollection('cms~ci~').find({"source":{"\$ne":"CLOUD"}},{"~id~":0,"source":1}); // \$ne不相待
-   db.cms~ciclass~.find({'createTime': {\$type:18}}); //查询数据类型为32-bit integer的数据 type:18
-   db.cms~ciclass~.find({'createTime': {\$type:18}}).limit(10); //    limit
-   db.cms~ciclass~.find({'createTime': {\$type:18}}).skip(10); // skip  跳过前10条
-   db.cms~ciclass~.find().sort({'name':1}); // 根据名称进行排序 1为升序，-1为降序
-   db.runCommand({'distinct':'cms\_ci\_class','key':'attributes.dataType'});  //distinct语句
-   db.cms~ciclass~.distinct('attributes.dataType'); distinct语句
-   db.getCollection('cms_api_log').find({'createTime':{$gte: new Date('2017-11-14')}})    // 查询日期；日期存储的时候使用java.util.Date，mongo会转成ISO格式，读出来的时候仍然是Date
-   db.getCollection('cms_api_log').find({'uri':/query/})   // like查询 '%query%'
-   db.getCollection('cms_api_log').find({'uri':/^query/})   // like查询 '%query'
-   db.getCollection('cms_api_log').find({'uri':/query$/})   // like查询 'query%'

### 其他操作

-   db.pengganyu.update({"title":"name"},{\$set:{"title":"pengganyu"}}):
    更新文档
-   db.pengganyu.save({xxxx}): 保存文档
-   db.pengganyu.remove({}): 移除所有的文档
-   db.pengganyu.remove({xxx}): 移除文档

索引
----

mongo当中的索引使用ensureIndex来操作，将所需要添加到索引的列标记为1，为正序排序

``` {.shell}
// db.getCollection('cms_ci').find({"dataFieldMap.id":"158b9616-d61a-4bbc-8da1-a4f35879a3d6"}); // 0.567s
// db.getCollection("cms_ci").ensureIndex({"dataFieldMap.id":1});
// db.getCollection('cms_ci').find({"dataFieldMap.id":"158b9616-d61a-4bbc-8da1-a4f35879a3d6"}); // 0.004s
```

-   每个集合的最大索引个数为64
-   建立索引的时候使用background参数，将建立过程在后台完成，不阻塞数据操作；
    db.getCollection("cms~ci~").ensureIndex({"dataFieldMap.id":1},{"background":true});

备份恢复
--------

-   mongodump -h dbhost -d dbname -o dbdirectory
-   mongodump -h localhost -d test -o /tmp/test
-   mongorestore -h localhost:27017 -d test test; // mongorestore -h
    &lt;hostname&gt;&lt;:port&gt; -d dbname
-   mongorestore -h localhost:27017 -d test  --dir *tmp/test --drop; /*
    先删除，再按照指定目录进行恢复

MongoShell
----------

mongo命令连接至mongoshell，在mongoshell当中，按tab键可以进行自动匹配的提示

-   show dbs; 查看当前的数据库实例列表
-   show users; 查看当前数据库实例当中的用户列表
-   use hf-cmdb5; 使用指定的数据库实例；若不存在则直接创建
-   db.stats(); 查看当前数据库实例的状态
-   db ; 返回当前的数据库实例
-   db.system.users.find().pretty(); 查看所有的用户列表
-   db.system.users.remove({user:'username'}); 删除用户

``` {.example}
    ➜  ~ mongo
    MongoDB shell version v3.4.7
   connecting to: mongodb://127.0.0.1:27017
    MongoDB server version: 3.4.7
    > 

    > show dbs;
    admin     0.000GB
    hf-cmdb5  0.013GB
    local     0.000GB
    test      0.348GB

    > db.stats()
    {
            "db" : "hf-cmdb",
            "collections" : 0,
            "views" : 0,
            "objects" : 0,
            "avgObjSize" : 0,
            "dataSize" : 0,
            "storageSize" : 0,
            "numExtents" : 0,
            "indexes" : 0,
            "indexSize" : 0,
            "fileSize" : 0,
            "ok" : 1
    }
```

### 添加用户

-   mongo 进入到mongoshell模式下

```
use admin;
//为admin创建用户名和密码及角色；此用户名和密码只适用于admin的db，虽然是admin，但是与其他的db的用户名密码不能通用
db.createUser({user:'dba',pwd:'dba',roles:[{role:'userAdminAnyDatabase',db:'admin'}]});


use hf-cmdb5

db.createUser({user:'dbuser',pwd:'dbuser',roles:[{role:'dbAdmin',db:'hf-cmdb5'}]});

// 测试用户名密码是否正确，返回1说明正确
db.auth({'user':'dbuser','pwd':'dbuser'});
```

### 角色说明

-   数据库用户：read，readWrite
-   数据库管理员角色：dbAdmin、dbOwner、userAdmin
-   集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager
-   备份恢复角色： backup、restore
-   所有数据库角色：
    readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
-   超级用户角色：root
    其中dbOwner、userAdmin、userAdminAnyDatabase可以对超级用户的访问
-   内部角色: ~system~

连接认证
--------

一些错误
--------

``` {.shell}
> show dbs;
2017-11-14T15:13:26.658+0800 E QUERY    [thread1] Error: listDatabases failed:{
        "ok" : 0,
        "errmsg" : "not master and slaveOk=false",
        "code" : 13435,
        "codeName" : "NotMasterNoSlaveOk"
} 
```

-   连接至从节点的时候，show
    dbs异常，这是因为从节点默认不允许读写操作，使用rs.slaveOk()设置slaveOk为true;
-   rs为 replSet，副本集

### 其他命令

```
rs.conf();

rs.status();

db.state();
```

### 一些问题

http://www.cnblogs.com/cswuyg/p/4355948.html