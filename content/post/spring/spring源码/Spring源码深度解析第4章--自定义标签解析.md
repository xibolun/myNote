---

date :  "2017-08-21T23:36:24+08:00" 
title : "Spring源码深度解析第4章--自定义标签解析" 
categories : ["技术文章"] 
tags : ["spring"] 
toc : true
---


4.1 自定义标签的使用
--------------------

-   为了方便非标准的spring bean配置，spring提供了自定义标签的功能
-   原理为使用spring提供AbstractBeanDefinitionParser来解析xml里面的元素数据，放到BeanDefinition当中
-   将BeanDefinition注册即可
-   此种配置方式在现实当中已经不常用，像现在的SpringBoot就不需要xml的配置
-   故此本章只需要知道，了解即可，没有必要深入学习

``` {.xml}
    <user email = "email",id="id></user>
```
