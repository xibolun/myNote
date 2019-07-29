---

date :  "2018-06-07T14:47:52+08:00" 
title : "Neo4j环境搭建" 
categories : ["技术文章"] 
tags : ["neo4j"] 
toc : true
---

## Neo4j环境搭建

### 安装启动

neo4j分为community和enterprise两种版本，后者属于企业版本，为付费版本；当前只针对community版本；

版本列表及下载地址

[neo4j-download]: https://neo4j.com/download/other-releases/#releases



由于下载版本耗时较长，我将3.0.4thsg下载后放到10.0.106.2服务器上

```
## 密码 yunjikeji
## 可以将/tmp目录替换为自己所需用的目录，这里为了方便设置为/tmp而已
scp root@10.0.106.2:/home/pengganyu/neo4j-community-3.4.0-unix.tar.gz /tmp
```

解压后展开目录层级如下：

```
.
├── bin    # neo4j、cypher脚本
│   └── tools
├── certificates #  认证的cert和key
├── conf 
├── data  # 数据文件
│   ├── databases
│   │   └── graph.db
│   │       └── index
│   └── dbms
├── import
├── lib
├── logs # log
├── plugins # 插件列表
└── run
```

启动

```
./bin/neo4j start
```

可以查看启动的log

```
tail -f logs/neo4j.log
```

```
2018-06-07 07:23:49.379+0000 INFO  ======== Neo4j 3.4.0 ========
2018-06-07 07:23:49.477+0000 INFO  Starting...
2018-06-07 07:24:04.957+0000 INFO  Bolt enabled on 127.0.0.1:7687.
2018-06-07 07:24:09.653+0000 INFO  Started.
2018-06-07 07:24:11.718+0000 INFO  Remote interface available at http://localhost:7474/
```

在浏览器当中打开http://localhost:7474即可看到web的控制台

初始化密码为neo4j/neo4j，修改密码后即可正常使用

### 官方教程

```
:play cypher
```

即可开始简易的cypher教程，按着教程即可学习创建节点，查询节点等

```
:play movie-graph
```

以一个电影和演员的关系数据，可以学习到关系查询、属性查询、删除节点等

```
:play northwind-graph
```

从在线的csv当中import数据，学习关系创建，创建索引，复杂查询等

### 常用语句

```
match n return distinct labels(n)//统计节点数量
```

```
match n return count(n) //统计节点数量
```

### 官方cypher文档

[3.4 cypher]: https://neo4j.com/docs/developer-manual/3.4/cypher/

