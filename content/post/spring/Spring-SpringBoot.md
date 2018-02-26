+++
date = "2017-04-27T23:36:24+08:00"
title = "Spring-SpringBoot"

+++

Spring 1.5.x当中的hibrenate名称转换策略
---------------------------------------

今天将Spring从1.3.2升级到1.5.x当中，发现所有的查询都会有异常信息，异常信息为小写的表名不存在，本来想修改一下MySQL对大小写的敏感配置就可以了，但是想着1.3版本的为什么就不会有这个问题呢？

``` {.shell}
### Spring 1.3版本当中的配置
spring.jpa.hibernate.naming-strategy=org.hibernate.cfg.DefaultNamingStrategy

### Spring 1.5版本当中的配置
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
```

由于1.5当中将hibrenate jar包升级，导致hibreanate的一些配置有所变化。
对于名称策略，官方描述如下：[Spring Configure JPA
properties](http://docs.spring.io/spring-boot/docs/1.5.0.RELEASE/reference/htmlsingle/#howto-configure-jpa-properties)

SpringBoot 配置myBaits的log输出
-------------------------------

配置logImpl的参数值即可，LOG4J是按照log4j的日志进行输出

``` {.xml}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <setting name="cacheEnabled" value="false" />
        <setting name="lazyLoadingEnabled" value="false" />
        <setting name="multipleResultSetsEnabled" value="true" />
        <setting name="useColumnLabel" value="true" />
        <setting name="useGeneratedKeys" value="false" />
        <setting name="defaultExecutorType" value="SIMPLE" />
        <setting name="mapUnderscoreToCamelCase" value="true" />
        <setting name="logPrefix" value="dao."/>
        <setting name="logImpl" value="LOG4J"/>
        <setting name="logImpl" value="STDOUT_LOGGING"/>
    </settings>
</configuration>
```
