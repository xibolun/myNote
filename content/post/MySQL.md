+++
date = "2017-04-27T23:36:24+08:00" title = "MySql日常杂学" categories = ["技术文章"] tags = ["mysql"] toc = true
+++

MySql日常杂学
=============

启动相关
--------

``` {.shell}
/etc/init.d/mysqld start
/etc/init.d/mysqld stop
/etc/init.d/mysqld restart

service mysqld restart
service mysqld stop
service mysqld start
```

其他命令
--------

``` {.shell}
mysql -uroot -pP@ssw0rd -h55.6.8.142 hf-csa --default-character-set=utf8
mysql -uoot -pP@ssw0rd hf-csa -default-character-set=utf8 < db_qdn672.sql
mysqldump --opt --protocol=TCP --user='root' --password='P@ssw0rd' --host='55.6.8.142' -all-databases  --result-file='20170619.sql'
mysqldump --opt --protocol=TCP --user='root' --password='P@ssw0rd' --host='55.6.8.142' hf-csa  --result-file='20170619.sql'
```

Index
-----

-   SHOW INDEX FROM SRV~INFO~; -- 查看表里面的索引信息
-   ALTER TABLE SRV~INFOWFNODEEXECLOG~ ADD INDEX
    SRV~INFOWFNODEEXECLOGINDEX1~(SRV~INFOWFNODEID~,FROM~STATE~,TO~STATE~);
    -- 添加索引
-   ALTER TABLE SRV~INFOWFNODEEXECLOG~ DROP INDEX
    SRV~INFOWFNODEEXECLOGINDEX1~; -- 删除索引

MySQL优化
---------

### 表字段

-   整数类型不要使用INT，使用TINYINT、SMALLINT、MEDIUM~INT~,非负添加UNSIGNED
-   VARCHAR的长度只分配真正需要的空间
-   使用TIMESTAMP而非DATETIME
-   单表字段不超过20
-   用整型来存IP

### 查询类

-   不用SELECT \*
-   OR改写为IN: or的效率是N级别，而IN的效率是Log(n)级别
-   WHERE的子句不用!=或者&lt;&gt;操作，否则引擎放弃使用索引而进行全表扫描

Mysql Dump
----------

### dump数据库

``` {.shell}
mysqldump -uroot -p hf-csa > hf-csa.sql
```

### 只dump数据库表结构（--no-data -d）

``` {.shell}
mysqldump -uroot -p --no-data --add-drop-table hf-csa > hf-csa.sql
mysqldump -uroot -p -d --add-drop-table hf-csa > hf-csa.sql
```

### dump数据库表结构排除某些表

``` {.shell}
mysqldump -uroot -p --no-data --add-drop-table hf-csa --ignore-table=hf-csa.ACT_GET_PROPERTY > hf-csa.sql
```

### dump数据库某张表，表中间以空格分隔

``` {.shell}
mysqldump -uroot -p --no-data hf-csa SRV_INFO SRV_BP_APP_INFO > hf-csa.sql
```

### dump数据库带注释的表结构

``` {.shell}
mysqldump -uroot -p --no-data --comments hf-csa SRV_INFO SRV_BP_APP_INFO > hf-csa.sql
```

### reload dump File

``` {.shell}
shell> mysql hf-csa < hf-csa.sql
shell> mysql -e "source hf-csa.sql" hf-csa
mysql> use `hf-csa`;
mysql> source hf-csa.sql 
```

INFOMATION~SCHEMA~
------------------

``` {.sql}
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'hf-csa'; // 查询hf-csa下所有表的列
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'hf-csa'; // 查询hf-csa下所有的表
```

``` {.sql}
 SHOW FULL COLUMNS FROM table_name;                          #查看mysql某表当中的列字段，包括列的character
 SHOW TABLE STATUS where name like 'SRV_BP_APP_NODE_VER';    # 查看某表的状态

```

语法相关
--------

### LEFT JOIN，RIGHT JOIN, INNER JOIN

-   LEFT JOIN：以左边的表为基准显示查询结果
-   RIGHT JOIN：以右边的表为基准显示查询结果
-   INNER JOIN：只显示符合条件的查询结果

``` {.shell}
SELECT ip.IP_ADDRESS,ip.ID,unit.NAME FROM SRV_BP_DEV_IP ip LEFT JOIN SRV_BP_DEV dev ON ip.SRV_BP_DEV_ID = dev.ID
  LEFT JOIN SRV_BP_APP_DP_UNIT unit ON dev.SRV_BP_APP_DP_UNIT_ID = unit.ID WHERE
  ip.SRV_INFO_ID = dev.SRV_INFO_ID AND dev.SRV_INFO_ID = unit.SRV_INFO_ID AND ip.SRV_INFO_ID = '9ecbd34c-3ed6-4e61-8d11-0ba526e9ca98';
```

问题列表
--------

### mysql的一些运维命令

``` {.shell}
# 查看mysql的端口监听情况
netstate -nlt | grep 3306
lsof -i:3306
# 查看mysql的进程，同时可以看到mysql的一些文件位置
ps ax | grep mysqld 
```

### ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)

``` {.mysql}
-- 进入安全模式
➜  ~ mysqld_safe --skip-grant-tables &

-- 直接无密码进入
➜  ~ mysql -uroot

-- 选择mysql
mysql> use mysql;

-- 修改密码
## 5.7以后 passowrd字段改为authentication_string
mysql> update user set password=PASSWORD("yunjikeji") where User = 'root';


-- flush 生效
mysql> flush privileges;

-- 再次用密码尝试登陆
➜  ~ mysql -uroot -p
```

### Incorrect definition of table performance~schema~.events~waitscurrent~: expected column 'NESTING~EVEN~

数据库结构错误，导致mysql启动异常

``` {.shell}
➜  ~ mysql_upgrade -u root -p
```

### MAC homebrew安装的mysql相关

-   my.cnf目录位于：/usr/local/Cellar/mysql/5.7.11/support-files/
-   启动相关命令：mysql.server start|stop|staus|restart

### Data source rejected establishment of connection, message from server: "Too many connections

由于mysql的连接数过大导致，修改最大连接数即可;

``` {.shell}
mysql> show VARIABLES  WHERE variable_name = 'max_connections';

mysql> set GLOBAL max_connections=200;
```

但是在启动java工程的时候仍然会报错，并且重新Mysql后，此值无法生效，又变成了默认值151（有的版本为100）；就想着修改mysql的默认配置文件；去找一个mac平台里面的my.cnf，但是没有；于是从/usr/local/Cellar/mysql/5.7.11/support-files/当中copy一个conf到/etc/my.cnf当中,在my.cnf当中设置max~connections即可~，这样每次启动Mysql，都会设置为默认的值；
在mac下/etc/my.cnf里面会自动加上权限为只读文件

``` {.shell}
[mysqld]
## set column max value
max_allowed_packet = 500M
max_connections=200

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
```


### mysql lock ###
[An InnoDB Deadlock Example](https://dev.mysql.com/doc/refman/8.0/en/innodb-deadlock-example.html)
[Deadlocks in InnoDB](https://dev.mysql.com/doc/refman/8.0/en/innodb-deadlocks.html)
