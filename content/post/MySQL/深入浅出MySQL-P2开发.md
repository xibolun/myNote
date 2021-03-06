---

date :  "2019-03-25T09:57:31+08:00" 
title : "深入浅出MySQL(二)" 
categories : ["技术文章"] 
tags : ["MySQL"] 
toc : true

---

### MySQL存储引擎

#### 各引擎之间的区别

| 特点         | MyISAM | InnoDB | MEMORY | MERGE | NDB  |
| ------------ | ------ | ------ | ------ | ----- | ---- |
| 存储限制     | 有     | 64TB   | 有     | 没有  | 有   |
| 事务安全     |        | 支持   |        |       |      |
| 锁机制       | 表     | 行     | 表     | 表    | 行   |
| B树索引      | 支持   | 支持   | 支持   | 支持  | 支持 |
| 哈希索引     |        |        | 支持   |       | 支持 |
| 全文索引     | 支持   |        |        |       |      |
| 集群索引     |        | 支持   |        |       |      |
| 数据缓存     |        | 支持   | 支持   |       | 支持 |
| 索引缓存     | 支持   | 支持   | 支持   | 支持  | 支持 |
| 数据可压缩   | 支持   |        |        |       |      |
| 空间使用     | 低     | 高     |        | 低    | 低   |
| 内存使用     | 低     | 高     | 中等   | 低    | 高   |
| 批量插入速度 | 高     | 低     | 高     | 高    | 高   |
| 支持外键     |        | 支持   |        |       |      |

#### 查看引擎

```shell
mysql> SHOW ENGINES \G

mysql>SHOW VARIABLES LIKE 'have%';

```

### InnoDB存储引擎

