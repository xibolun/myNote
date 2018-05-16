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
