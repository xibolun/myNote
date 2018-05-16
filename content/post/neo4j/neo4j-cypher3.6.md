+++
date = "2018-05-16T09:29:45+08:00" title = "neo4j-cypher3.6" categories = ["技术文章"] tags = ["neo4j"] toc = true
+++

## 3.6 Query tuning

### cypher query options

```
CYPHER planner=rule match  (n) return labels(n)
```

### profile

作用是查看查询计划。那什么叫查询计划(Query Plan)？neo4j在查询的时候，会将一个查询语句分解成多个小片，称为运算(Operators)将这些运算的结果最后连接在一起，这样的模式(pattern)叫作查询计划。现在的查询计划，neo4j支持了图表展示。

#### EXPLAIN

```
EXPLAIN   match  (n) return labels(n)
```

EXPLAIN不真正去执行语句，而返回一个空的结果，但是可以让你看到查询的过程

![explain-profiling.png](http://oxmycii3v.bkt.clouddn.com/20180516100903.png)

查询计划图说明：

- AllNodesScan: Operator name
- 320 estimated rows: 分析了320行
- AllNodesScan的结果做为input，进入到Projection的运算当中，产出了320行数据，再进入最后的产出结果运算
- Projection当中的
  - lables(n),n: 标识符(Identifiers)
  - LabelsFunction(n): 表达式
- runtime: INTERPRETED   ————由于explain不真正执行结果，所以runtime为演绎时间

#### PROFILE

```cypher
PROFILE MATCH (n) return labels(n)
```

![profile-profiling.png](http://oxmycii3v.bkt.clouddn.com/img/neo4j/profile-profiling.png)

PROFILE的执行过程与EXPLAIN的类似，但是PROFILE的执行是真正在操作数据库，所以会有db hits；同时runtime也为真实的数值

```cypher
profile match (n{code:'A_ENDS'}) return n;
profile match (n:egfbank_BpAppInfo {code:'A_ENDS'}) return n;
create index on : BpAppInfo(code)
profile match (n:egfbank_BpAppInfo {code:'A_ENDS'}) return n;
profile match (n:egfbank_BpAppInfo)  USING index  n:egfbank_BpAppInfo(code)  where n.code= 'A_ENDS'   return n;
```

- 第一条会查询所有的节点，耗时比较长
- 第二条会查询指定的label
- 第三条会根据建立的索引去做查询
- 可以指定index去做查询

### USING keyword

在查询过程当中，可以使用USING关键字，去指定查询过程；

#### USING index

```
MATCH (n:default_BpAppInfo{typeCode:'dfdasa'}) USING index n:default_BpAppInfo(typeCode)  return n.typeCode;
```

#### USING SCAN

在大数据查询的情况下，MATCH的查询会比较慢，若是单个的NODE查询，可以使用SCAN指定遍历的NODE节点，提高查询效率；数据量小的情况下使用SCAN没有意义

```
PROFILE MATCH (n:default_BpAppInfo) USING SCAN n:default_BpAppInfo return n;
```

#### PERIODIC COMMIT

此项仅在使用load csv文件时有效；USING PERIODIC COMMIT 500的意思是说：在处理大量数据的时候，一个事务可以提交500条数据，到达500条之后，事务会提交并刷新一个新的事务进行处理其他的数据，至到数据处理完成；若没有指定500，那么将以默认值(这个默认值是多少？)进行运算。

#### 