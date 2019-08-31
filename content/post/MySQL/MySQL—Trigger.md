---
date :  "2019-08-01T11:15:04+08:00" 
title : "MySQL Trigger" 
categories : ["技术文章"] 
tags : ["mysql"] 
toc : true
---

## MySQL Trigger

 [trigger](https://dev.mysql.com/doc/refman/5.7/en/create-trigger.html) 是一个触发器，用于在新增、修改和删除数据的时候做一些额外的操作。

- 全局惟一，所有建的trigger不能重名
- 不能对`TEMPORARY`表进行操作
- 必须与表进行绑定，不能操作视图
- 由于是针对于每一行的，所以请慎用

### 使用

```sql
-- 建表
DROP TABLE IF EXISTS `PERSON`;
CREATE TABLE `PERSON`(
  `ID`     INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `NAME`   VARCHAR(64) DEFAULT NULL COMMENT '姓名',
  `AGE`    INT(10)     DEFAULT NULL COMMENT '年龄',
  `REMARK` VARCHAR(64) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`ID`)
) ENGINE = INNODB AUTO_INCREMENT = 101 DEFAULT CHARSET = UTF8;
```

```sql
-- create trigger
CREATE TRIGGER TRIGGER_PERSON BEFORE INSERT ON PERSON
  FOR EACH ROW
BEGIN
  IF NEW.AGE < 10 THEN
    SET NEW.REMARK = '儿童';
  ELSEIF NEW.AGE > 10 AND NEW.AGE < 18 THEN
    SET NEW.REMARK = '未成年';
  ELSEIF NEW.AGE > 18 THEN
    SET NEW.REMARK = '成年人';
  END IF;
END;
```

```sql
-- test
INSERT INTO PERSON(NAME, AGE, REMARK) VALUES ('小锦', 9, '');
INSERT INTO PERSON(NAME, AGE, REMARK) VALUES ('小明', 10, '');
INSERT INTO PERSON(NAME, AGE, REMARK) VALUES ('小兰', 12, '');
INSERT INTO PERSON(NAME, AGE, REMARK) VALUES ('小黄', 18, '');
INSERT INTO PERSON(NAME, AGE, REMARK) VALUES ('小芳', 20, '');

101	小锦	9	儿童
102	小明	10	""
103	小兰	12	未成年
104	小黄	18	""
105	小芳	20	成年人
```

### 其他

- 新增与修改的trigger [trigger语法](https://dev.mysql.com/doc/refman/5.7/en/trigger-syntax.html)

- 查看所有的triggers

```
SELECT * FROM information_schema.TRIGGERS;
```

- 查看triggers

```
SHOW TRIGGERS ;
```

