+++
date = "2017-12-26T23:36:24+08:00" title = "Neo4j JavaReference" categories = ["技术文章"] tags = ["Neo4j"] toc = true
+++

## Neo4j JavaReference ##

### Extending Neo4j ###

#### 自定义程序 ####
neo4j里面有一套程序模板，可以让用户进行使用并调用  [neo4j-procedure-template](https://github.com/neo4j-examples/neo4j-procedure-template) 

#### 内置程序列表 ####

   * db.constraints	
   * db.indexes	
   * db.labels	
   * db.propertyKeys	
   * db.relationshipTypes	
   * dbms.changePassword
   * dbms.components	
   * dbms.procedures	
   * dbms.queryJmx 
   
### 远程debugger ###
在neo4j.conf文件当中设置

```
dbms.jvm.additional=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005

```

### 使用neo4j ###

#### org.neo4j:neo4j ####

  * GraphDatabaseSettings: 记录着neo4j的一些参数设置信息 
  * 可以指定目录，指定配置文件，指定配置启动

``` java
GraphDatabaseService graphDb = new GraphDatabaseFactory()
    .newEmbeddedDatabaseBuilder( testDirectory.graphDbDir() )
    .setConfig( GraphDatabaseSettings.pagecache_memory, "512M" )
    .setConfig( GraphDatabaseSettings.string_block_size, "60" )
    .setConfig( GraphDatabaseSettings.array_block_size, "300" )
    .newGraphDatabase();
```
  

#### OGM ####

#### SDN ####


