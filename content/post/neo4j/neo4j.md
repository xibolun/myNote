+++
date = "2017-12-04T22:38:37+08:00" title = "neo4j-基础学习" categories = ["技术文章"] tags = ["neo4j"] toc = true
+++

## 索引 

建立索引

```cypher
create index on : BpAppInfo(code)
Added 1 index, statement executed in 157 ms.
```

查看索引

```cypher
call db.indexes
```

删除索引

```cypher
drop index on : BpAppInfo(code)
```

#### profile

作用是查看查询计划，

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


#### 修改密码

```
curl -H "Content-Type: application/json" -XPOST -d '{"password":"new password"}' -u neo4j:neo4j http://localhost:7474/user/neo4j/password
```

