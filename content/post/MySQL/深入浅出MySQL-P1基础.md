---

date :  "2019-03-28T09:56:53+08:00" 
title : "深入浅出MySQL(一)" 
categories : ["技术文章"] 
tags : ["MySQL"] 
toc : true

---

### DDL、DML、DCL

- Data Definition Languages: 数据定义语句，drop、create、alter、change、modify等
- Data Manipulation Languages: 数据操纵语句，insert，delete，update等
- Data Control Languages: 数据控制语句，grant、revoke等

### MySQL版本说明

### 其他

- 使用?可以查看命令的帮助信息

```
mysql> ? CREATE DATABASE
Name: 'CREATE DATABASE'
Description:
Syntax:
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
    [create_specification] ...

create_specification:
    [DEFAULT] CHARACTER SET [=] charset_name
  | [DEFAULT] COLLATE [=] collation_name

CREATE DATABASE creates a database with the given name. To use this
statement, you need the CREATE privilege for the database. CREATE
SCHEMA is a synonym for CREATE DATABASE.

URL: http://dev.mysql.com/doc/refman/5.6/en/create-database.html
```

### DateTime与Timestamp的区别

- 当时区一致的时候两者的日期没有什么区别，但是时区不一致的时候，Timestamp取的是系统所在时区的时间；而DateTime取的是指定时区的当前时间
- Timestamp支持的时间范围比较小【19700101080001 ~ 2038-01-19 11:14:07】
- 若数据类型为Timestamp时，字段为Null，则写入的是系统当前时间

### CHAR与VARCHAR的区别

- char为定长，varchar为可变长度
- char的范围为0~255，而varchar的范围0~65535
- char在检索的时候会去掉空格，而varchar会保留空格