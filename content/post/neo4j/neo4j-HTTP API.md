---

date :  "2018-05-25T10:41:32+08:00" 
title : "Neo4j HTTP API" 
categories : ["技术文章"] 
tags : ["neo4j"] 
toc : true
---

## HTTP API

http endpoint支持单条和多条语句；超时时间默认是60s，可设置<u>dbms.rest.transaction.idle_timeout</u>；

需要添加authorization在http headers当中

### 单多语句提交

```
curl -X POST \
  http://localhost:7474/db/data/transaction/commit \
  -H 'authorization: Basic bmVvNGo6UEBzc3cwcmQ=' \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{
  "statements": [
    {
      "statement": "match (n) return labels(n)"
    }
  ]
}'
```



### 多条语句提交

```
curl -X POST \
  http://localhost:7474/db/data/transaction/commit \
  -H 'authorization: Basic bmVvNGo6UEBzc3cwcmQ=' \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{
  "statements": [
    {
      "statement": "match (n) return count(n)"
    },{
    	"statement":"match ()-->() return count(*)"
    }
  ]
}'
```

