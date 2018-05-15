+++
date = "2018-04-16T21:10:32+08:00" title = "Neo4j-官网开发手册（三）--cypher" categories = ["技术文章"] tags = ["neo4j"] toc = true

+++



## 3.2 语法

### 命名与建议

- 节点建议使用驼峰，关系使用大写，下划线分隔
- 查询语句当中的空格会被替换掉
- 查询语句当中若有数字，数字不能放在第一个
- 节点区分大小写:PERSON :Person and :person 是三个不同的节点

### 基础表达式

- 支持true、false、TRUE、FALSE的boolean类型
- 支持八进制和十六进制字符
- 支持动态属性? n["param"]
- 支持参数 $param
- 转义： \t、\b、\n、\r…….


### 运算符（Operators）

- ^、%、/、*、+、- 
- <>、=、>、<、>=、<=
- IS NULL、IS NOT NULL
- String运算符： STARTS WITH、ENDS WITH、CONTAINS
- XOR、NOT、AND、OR
  - true XOR true  = false  // XOR只有在同时为true或false的时候才为false
  - false XOR false = false
  - null XOR null = null
  - NOT null = null
- IN
  - 2 IN [1, `null`, 3] = null
  - 2 IN [1, 2, `null`] = true
  - 2 IN [1] = false
  - null in [1,null,3] = null
  - null in []  =false

### CASE…WHEN

```cypher
match (n:egfbank_AppInfo) RETURN  CASE (n.`系统功能概述`) when '4324' then 2 else 3 end as result
```

```cypher
MATCH (n:egfbank_BpServer) RETURN case n.`主机名` when 'BJS0-076' then 2 when 'bjs0-a72-oa12' then 1 else 3 end AS `主机名`
```

- 属性的引号不是单引，也不是双引号，而是``
- 返回的别名也是``
- case when表达式在return之后
- 若不加result，则返回的key为【CASE (n.`系统功能概述`) when '4324' then 2 else 3 end】
- 支持多个then when

### 查询模式

- 不加关系查询，连接条件为  - - > 
- 可以添加label

```cypher
match(app:egfbank_AppInfo)--> (app2:egfbank_DbServer) return app,app2.主机名 AS `主机名`
```

```cypher
(a)-->(b)<--(c)
```

```cypher
(a)-->()<--(c)
```

- 关系上指定属性

```cypher
(a)-[{blocked: false}]->(b)
```

- 若a和b有可能存在两种关系

```cypher
(a)-[r:TYPE1|TYPE2]->(b)
```

- 关系层次查询

```cypher
(a)-[*2]->(b)//两层关系
```

- 可以直接使用RETURN

```cypher
return size([0,1,2])
return size(range(0,2))
return [x in range(0,2) where x%2=0 ] as result  // in和range的写法有点像python
```

## 3.3 从句(clauses)

### Match

- 忽略关系类型和方向

```cypher
MATCH (director { name: 'Oliver Stone' })--(movie)  RETURN movie.title
```

- 添加方向

```cypher
MATCH (:Person { name: 'Oliver Stone' })-->(movie) RETURN movie.title
```

- 不加具体关系类型，此方式可以用于计算两个节点之间的关系类型 type(r)

```
match(app:egfbank_AppInfo) -[r] -> (app2:egfbank_DbServer) return type(r)
```

- 多条关系查询；  两个关系类型中间用  |  进行区分

```
MATCH (wallstreet { title: 'Wall Street' })<-[:ACTED_IN|:DIRECTED]-(person)
RETURN person.name
```

- 关系层级

```
MATCH (martin { name: 'Charlie Sheen' })-[:ACTED_IN*1..3]-(movie:Movie)
RETURN movie.title
```

- 关系添加条件

```
MATCH p =(charlie:Person)-[* { blocked:false }]-(martin:Person)
WHERE charlie.name = 'Charlie Sheen' AND martin.name = 'Martin Sheen'
RETURN p
```

- 带参数查询

```
MATCH (n:egfbank_AppInfo) where n.`系统名称` = {pro} return n  // 3.0版本
MATCH (n:egfbank_AppInfo) where n.`系统名称` = $pro return n  // 3.2以上版本
```

### With

可以将match出来的结果进行一次聚合，然后再return；结合order by 和limit使用

```
MATCH (david { name: 'David' })--(otherPerson)-->()
WITH otherPerson, count(*) AS foaf
WHERE foaf > 1
RETURN otherPerson.name
```

```
MATCH (n)
WITH n
ORDER BY n.name DESC LIMIT 3
RETURN collect(n.name)//排序后再返回
```

### Unwind

将一个列表，转换成个体；最常用的是创建一个不重复的序列，或者从将一个列表当中的元素做为查询参数

- 将list转换成个体

```
UNWIND [1, 2, 3, NULL ] AS x return x  // 1,2,3,null
```

- 拆分多级list

```
with [[1,2],[3,2],[3,4]] as col 
unwind col as x 
unwind x as y  
return y
```

- 去重List

```
with [1,2,3,2,3,4] as col 
unwind col as x 
with distinct x 
return collect(x) as res
```

- 若list为空，需要加case

```
WITH [] AS list
UNWIND
   CASE
      WHEN list = []
         THEN [null]
      ELSE list
   END AS emptylist
RETURN emptylist
```

### Where

- 可以根据label去查询，Swedish为label

```
MATCH (n:egfbank_AppInfo)
RETURN n.name, n.age
```

```
MATCH (n)
WHERE n:egfbank_AppInfo
RETURN n.name, n.age
```

以上两者查询速率没有什么区别

- 查询属性是否存在

```
MATCH (n)
WHERE exists(n.belt)
RETURN n.name, n.belt
```

- 查询条件忽略大小写

```
MATCH (n)
WHERE n.name =~ '(?i)ANDR.*'
RETURN n.name, n.age
```

- 没有关系的查询

```
MATCH (persons),(peter { name: 'Peter' })
WHERE NOT (persons)-->(peter)
RETURN persons.name, persons.age
```

- 根据关系类型查询

```
MATCH (n)-[r]->()
WHERE n.name='Andres' AND type(r)=~ 'K.*'
RETURN type(r), r.since
```

### Order By

- 默认是asc排序
- null排在最后

### SKIP & LIMIT

- skip：跳过几个
- limit：只显示几个
- 两者可以配合使用，取中间的数据

### Create

- 单参数创建

```
{
  "props" : {
    "name" : "Andres",
    "position" : "Developer"
  }
}

CREATE (n:Person $props)
RETURN n
```



- 多参数创建

```
{
  "props" : [ {
    "name" : "Andres",
    "position" : "Developer"
  }, {
    "name" : "Michael",
    "position" : "Developer"
  } ]
}
//用unwind将列表解开，依次创建
UNWIND $props AS map
CREATE (n)
SET n = map
```

### Delete

- 删除节点  delete n
- 删除关系  delete rel
- 删除节点并关系  detach delete n

### Set

用于新增和修改节点标签或节点和关系的属性

- 新增节点标签

```
MATCH (n { name: 'Stefan' })
SET n:German
RETURN n.name, labels(n) AS labels
```

- 新增属性

```
MATCH (n { name: 'Andres' })
SET n.position = 'Developer', n.surname = 'Taylor'
```

- 删除属性

```
MATCH (n { name: 'Andres' })
SET n.name = NULL RETURN n.name, n.age
```

### Remove

删除节点标签或属性

- 删除属性

```
MATCH (a { name: 'Andres' })
REMOVE a.age
RETURN a.name, a.age
```

- 删除节点标签

```
MATCH (n { name: 'Peter' })
REMOVE n:German
RETURN n.name, labels(n)
```

### foreach

- 循环添加属性

```
MATCH p =(begin)-[*]->(END )
WHERE begin.name = 'A' AND END .name = 'D'
FOREACH (n IN nodes(p)| SET n.marked = TRUE )
```

