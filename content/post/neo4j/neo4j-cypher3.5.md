+++
date = "2018-05-02T11:16:31+08:00" title = "neo4j-cypher3.5" categories = ["技术文章"] tags = ["neo4j"] toc = true
+++

## 3.5 索引

- 索引分为单属性索引(*single-property index*)和组合属性索引(*composite index*)

### create single-property index

```cypher
CREATE INDEX ON :defautl_BpAppInfo(id)
```

查询索引列表

```cypher
CALL db.indexes
```

删除索引

```
drop index on :default_BpAppInfo(id);
```

### create compostive index

```cypher
CREATE INDEX on :default_BpAppInfo(typeCode,name)
```

注意：旧版本不支持索引逗号分隔操作

### profile

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