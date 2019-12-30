---
date :  "2019-11-05T16:37:18+08:00" 
title : "SaltStack(九)salt-returner" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

## Returner

`salt`支持的[`returners`列表](https://docs.saltstack.com/en/latest/ref/returners/all/index.html#all-salt-returners)

查看当前salt-minion上面支持多少returner，有的环境可以没有装太多的`returner`

```shell
salt '*' sys.list_returners
```

### Returner原理

![external-job-cache](/img/salt/external_job.png)

master下发指令后，minion将结果返回给master，同时写一份数据至其他扩展的系统，可以是mysql、mongo、syslog、stmp等；

github上面写的有现成的第三方组件 [salt-returners](https://github.com/saltstack/salt/tree/master/salt/returners) 

#### MySQL Returner

官网link： [salt.returners.mysql](https://docs.saltstack.com/en/latest/ref/returners/all/salt.returners.mysql.html#module-salt.returners.mysql)

##### Master端配置

查看已经当前`salt`版本已经支持的returners

```
salt '*' sys.list_returners
```

若不支持`mysql`，进行如下操作，若已经支持，则忽略

下载 [mysql.py](https://github.com/saltstack/salt/blob/master/salt/returners/mysql.py) 至`/srv/salt/_returners`目录下，使用以下任何命令进行同步

- [`state.apply`](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.state.html#salt.modules.state.apply_)
- [`saltutil.sync_returners`](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.saltutil.html#salt.modules.saltutil.sync_returners)
- [`saltutil.sync_all`](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.saltutil.html#salt.modules.saltutil.sync_all)

##### Minion端配置

安装`MySQL-python`

```shell
yum install -y MySQL-python
```

修改配置文件`/etc/salt/minion`

```yaml
return: mysql
mysql.host: 'xxxxx'
mysql.user: 'root'
mysql.pass: 'xxxxx'
mysql.db: 'salt'
mysql.port: 3306
```

以下的数据库当中需要创建如下`SQL`：

```
CREATE DATABASE  `salt`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `salt`;

--
-- Table structure for table `jids`
--

DROP TABLE IF EXISTS `jids`;
CREATE TABLE `jids` (
  `jid` varchar(255) NOT NULL,
  `load` mediumtext NOT NULL,
  UNIQUE KEY `jid` (`jid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE INDEX jid ON jids(jid) USING BTREE;

--
-- Table structure for table `salt_returns`
--

DROP TABLE IF EXISTS `salt_returns`;
CREATE TABLE `salt_returns` (
  `fun` varchar(50) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `return` mediumtext NOT NULL,
  `id` varchar(255) NOT NULL,
  `success` varchar(10) NOT NULL,
  `full_ret` mediumtext NOT NULL,
  `alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `id` (`id`),
  KEY `jid` (`jid`),
  KEY `fun` (`fun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `salt_events`
--

DROP TABLE IF EXISTS `salt_events`;
CREATE TABLE `salt_events` (
`id` BIGINT NOT NULL AUTO_INCREMENT,
`tag` varchar(255) NOT NULL,
`data` mediumtext NOT NULL,
`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
`master_id` varchar(255) NOT NULL,
PRIMARY KEY (`id`),
KEY `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

执行命令

`salt '*' test.ping --return mysql`

查询数据

`SELECT * FROM salt_returns;`

#### Mongo Return

Master同样的操作

##### Minion

安装pymongo依赖

```
yum install pymongo -y
```

修改配置文件`/etc/salt/minion`

```shell
return: mongo
mongo.db: salt
mongo.host: xxxx
mongo.user: root
mongo.password: xxxx
mongo.port: 27017
```

#### Redis Return

Master同样操作

##### Minion

安装python redis

```
yum install python2-redis -y
```

修改配置文件`/etc/salt/minion`

```
return: redis
redis.db: '0'
redis.host: 'salt'
redis.port: 6379
```

执行命令

`salt '*' test.ping --return redis`

查看redis结果

```
127.0.0.1:6379> keys *
 1) "ret:20191230212420062280"
 2) "F6572042-D38D-464D-0A2E-80ACAD430903:state.highstate"
 3) "ret:req"
 4) "F6572042-D38D-464D-0A2E-80ACAD430903:cmd.run"
 5) "ret:20191230212656663741"
 6) "ret:20191230212954734477"
 7) "F6572042-D38D-464D-0A2E-80ACAD430903:test.ping"
 8) "ret:20191230212927159795"
 9) "minions"
10) "F6572042-D38D-464D-0A2E-80ACAD430903:saltutil.sync_returners"
```



### 自定义Returner

[writting-a-returner](https://docs.saltstack.com/en/latest/ref/returners/#writing-a-returner)