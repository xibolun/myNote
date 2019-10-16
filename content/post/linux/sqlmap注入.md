---
date :  "2019-09-11T15:56:01+08:00" 
title : "sql注入--sqlmap" 
categories : ["技术文章"] 
tags : ["安全"] 
toc : true
---

## sql注入--sqlmap

### 介绍

[sqlmap](https://github.com/sqlmapproject/sqlmap)是一个sql注入的测试工具，用于测试接口或者数据库的安全性，是否存在sql注入的情形，功能很强大；

- 支持所有的数据库
- 支持所有的sql注入场景
- 支持直连操作
- 支持http请求，https；post\get，配置cookie，agent，header、referer
- 支持最大连接测试，重试次数
- 还有一些其他的特性  [Features](https://github.com/sqlmapproject/sqlmap/wiki/Features)

### sql注入

#### url注入

```shell
[root@cloudboot sqlmap]# ./sqlmap.py -u  "http://10.0.3.1/api/cloudboot/v1/devices/settings?sn=3Q28&page=1&page_size=10"  --cookie "access-token=eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiLotoXnuqfnrqHnkIblkZgiLCJ1c2VySWQiOiI1OWRmNTk2MGNkNmFjMzVmNTMxMzViMzEiLCJuYW1lIjoi6LaF57qn566h55CG5ZGYIiwibG9naW5JZCI6ImFkbWluIiwibG9naW5OYW1lIjoiYWRtaW4iLCJ0ZW5hbnRJZCI6ImRlZmF1bHQiLCJ0aW1lb3V0IjoyMTYwMCwiZXhwIjoxNTY4MjA2NzAxLCJjcmVhdFRpbWUiOjE1NjgxODUxMDE5MTAsInRlbmFudE5hbWUiOiLnrqHnkIbnp5_miLcifQ.JS2KtTbiHlLx8eLEUy87Ui_PrPKxYekmqYzFEfex3F4" --level 1 --current-user
.........
.........
[15:49:49] [INFO] the back-end DBMS is MySQL
web application technology: Nginx 1.14.2
back-end DBMS: MySQL >= 5.0.12
[15:49:49] [INFO] fetching current user
..........
current user:   None
[15:49:51] [WARNING] HTTP error codes detected during run:
500 (Internal Server Error) - 6 times
[15:49:51] [INFO] fetched data logged to text files under '/root/.sqlmap/output/10.0.3.1'

[*] ending @ 15:49:51 /2019-09-11/
```

post带参数请求

``` shell
/sqlmap.py -u "http://localhost:8083/api/osinstall/v1/user/login" --data '{"username":"admin","password":"admin","language":"ZH"}' --method POST
```


#### 直连

```shell
./sqlmap.py -d "mysql://root:xxxxxx@localhost:3306/xxxxxx" -f --banner --dbs --users
```

```
[22:14:16] [INFO] fetching database users
database management system users [4]:
[*] 'mysql.session'@'localhost'
[*] 'mysql.sys'@'localhost'
[*] 'root'@'%'
[*] 'root'@'localhost'

[22:14:16] [INFO] fetching database names
available databases [10]:
[*] .....
[*] sys
```

当前数据库

```shell
./sqlmap.py -d "mysql://root:xxxxxx@localhost:3306/xxxxxx" --current-db
[22:33:54] [INFO] fetching current database
current database: 'xxxxxx'
```

当前用户

```shell
./sqlmap.py -d "mysql://root:xxxxxx@localhost:3306/xxxxxx" --current-user
[22:34:34] [INFO] fetching current user
current user: 'root@localhost'
```

列出当前的表

```shell
./sqlmap.py -d "mysql://root:Yunjikeji#123@localhost:3306/cloudboot" -D xxxxxx --tables
[22:35:54] [INFO] fetching tables for database: 'xxxxxx'
Database: xxxxxx
[67 tables]
```

列出某张表的字段

```
./sqlmap.py -d "mysql://root:Yunjikeji#123@localhost:3306/cloudboot" -D xxxxxx -T platform_configs --columns
[22:42:38] [INFO] fetching columns for table 'platform_configs' in database 'xxxxxx'
Database: xxxxxx
Table: platform_configs
[6 columns]
```

其他的一些操作  [usage](https://github.com/sqlmapproject/sqlmap/wiki/Usage#usage) ;sql注入问题可以使用orm框架进行很好的避免，不要自己去拼装sql语句。
