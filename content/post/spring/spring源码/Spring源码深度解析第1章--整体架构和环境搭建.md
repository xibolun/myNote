+++
date = "2017-08-03T23:36:24+08:00"
title = "Spring源码深度解析第1章--整体架构和环境搭建"

+++

学习说明
--------

### 在看到第五章的时候有以下心得

看源码是一个枯燥的过程，因为你并没有参与到实际的开发和设计当中，所以有一些命名和思路不会非常明确，并且写代码的人的风格和思维都和自己不太一样；在学习的过程当中有很多的难题

-   看了源码可以做什么？
-   这是什么鬼东西
-   为什么要这样写？
-   这代码注释都不明确
-   看了半天，也许又得回到起点重新再看一遍，思路断了
-   类层级很深，根本不知道哪个调用哪个
-   无助，焦虑让自己无法承受

但是还是坚持下去，自己的路只能自己走，并且要坚持下去；也许坚持下去没有意义，也许会有意义；在这个过程当中的经历我反正享受到了，这样就够了。

### 在看到第七章的时候有以下心得

-   AOP自己现在已经大概会用了，但是原理在看的过程当中还是非常的吃力
-   准备第一遍看看大纲，知道一个大概，后续在第二遍的时候争取弄懂原理
-   静态和动态的代理模式在日常工作当中使用较少，没有细看

### 在看到第11章之后有以下心得

-   目前发现Spring
    Boot的起来，导致Spring的使用方式发生一些变化，准备看Spring
    Boot的一些东西
-   像JMS，事务，RPC等使用方式也不太一样，准备把Spring Boot好好用用
-   当然Spring Boot是基于Spring开发的，所以源码在一定程度上是通用的

Spring的整体架构
----------------

### CoreContainer

-   Core、 Beans、Context、 Expression、 Language

### Data Access/Integration

-   JDBC、ORM、 OXM、JMS、Transaction

### WEB

-   WEB、WEB-Servlet、WEB-Struts、Web-Porlet

### AOP

-   Aspects 、 Instrumentation

### Test

环境搭建
--------

原本以为导入工程是一个非常简单的事情，但是spring的编译采用了gradle；之前没有使用过
*gradle* ，所以费了一些事；

-   github地址：git@github.com:spring-projects/spring-framework.git
-   最新版本的spring-framework要求jdk 1.8以上版本
-   gradle环境搭建: [官网搭建手册](https://gradle.org/install/)
    ,我使用了homebrew，网速不给力，直接FANQIANG;设置代理 export
    https~proxy~=<http://localhost:8090>
-   有导入和eclipse和idea两种，分别对应两个md文件的说明，我采用了idea导入
-   编译工程并下载jar包： gradle
    build.gradle，大概需要下载6125个jar包的样子
-   导入idea，需要配置gradle的HOME；
    /usr/local/Cellar/gradle/4.1/libexec
-   导入idea，需要配置java的环境变量：jdk1.8

