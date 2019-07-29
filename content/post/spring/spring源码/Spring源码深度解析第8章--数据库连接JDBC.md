---

date :  "2017-09-12T23:36:24+08:00" 
title : "Spring源码深度解析第8章--数据库连接JDBC" 
categories : ["技术文章"] 
tags : ["spring"] 
toc : true
---

前言
----

-   什么是JDBC（Java DataBase Connectivity Java数据库连接）
-   怎么使用JDBC？
    1.  引入数据库驱动jar包
    2.  Java在程序当中加载驱动Class.forName("com.mysql.jdbc.Driver")
    3.  创建数据库对象
    4.  创建statement对象
    5.  调用Statement对象执行sql语句
    6.  关闭数据库连接
-   其他像Spring Data
    Jpa或者使用mybatis，或者Hibernate等框架也可以完成数据库的操作
-   此章不再这里做展开

