+++
date = "2017-09-12T23:36:24+08:00"
title = "Spring源码深度解析第9章--MyBatis整合"

+++

前言
----

-   [MyBatis](http://www.mybatis.org/mybatis-3/zh/index.html)
    之前叫iBatis，是Apache的一个开源项目，后来迁移到了Google
    Code当中，改名为MyBatis
-   官网介绍如下：MyBatis 是一款优秀的持久层框架，它支持定制化
    SQL、存储过程以及高级映射。MyBatis 避免了几乎所有的 JDBC
    代码和手动设置参数以及获取结果集。MyBatis 可以使用简单的 XML
    或注解来配置和映射原生信息，将接口和 Java 的 POJOs(Plain Old Java
    Objects,普通的 Java对象)映射成数据库中的记录。

与Spring Boot整合
-----------------

### 基本整合

因为当前最流行的是Spring boot框架，所以在将Spring boot与MyBatis整合一下

``` {.shell}
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>1.3.0</version>
</dependency>
```

``` {.java}
package com.idcos.automate.dal.mybatis;

import com.idcos.automate.dal.auto.dataobject.xl.BibleTextDO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface BibleTextMapper {

    @Select("SELECT * FROM BIBLE_TEXT WHERE ID = #{id}")
    BibleTextDO findOne(@Param("id") String id);
}
```

``` {.java}
package com.idcos.gen;

import com.idcos.Application;
import com.idcos.automate.dal.mybatis.BibleTextMapper;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.web.WebAppConfiguration;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
@WebAppConfiguration
public class MybatisTest {

    @Autowired
    private BibleTextMapper bibleTextMapper;

    @Test
    public void testFindOne() {
        System.out.println(bibleTextMapper.findOne("1"));
    }
}
```

-   注意若MyBatis版本太低，不存在@Mapper注解，当前工程MyBatis版本号为3.4.4

#### 参考

\[\[\*\* <https://github.com/mybatis/spring-boot-starter>\]\[MyBatis
Spring-Boot-Starter\]\]

### xml整合

-   引入依赖

``` {.shell}

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.7.RELEASE</version>
        <relativePath /> 
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- 1.3.0 -->
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>${mybatis.spring.boot.starter}</version>
        </dependency>

        <!-- DB -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql.connector.version}</version>
        </dependency>
<dependencies>
```

-   配置数据源及mapper路径

``` {.shell}
#server.port=8080
spring.profiles.active=local
spring.jpa.database=MYSQL
spring.jpa.show-sql=true
spring.jpa.hibernate.naming-strategy=org.hibernate.cfg.DefaultNamingStrategy
spring.datasource.username=root
spring.datasource.url=jdbc:mysql://mysql.dev.idcos.net:3306/gf-csa?characterEncoding=UTF-8&useSSL=false
spring.datasource.password=P@ssw0rd
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.test-on-borrow=true
spring.datasource.validation-interval=30
spring.datasource.validation-query=SELECT 1

# mybatis
mybatis.mapper-locations=classpath:mapper/*.xml
## 表结构别名，配置PO对象所在的包路径
mybatis.type-aliases-package=com.idcos.automate.dal.auto.dataobject

```

-   配置mapper接口类

``` {.java}
package com.idcos.automate.dal.mybatis;

import com.idcos.automate.dal.auto.dataobject.xl.BibleBookDO;

import java.util.List;

public interface BibleBookMapper {

    List<BibleBookDO> findAll();
}
```

-   配置mapper接口所对应的xml文件

``` {.xml}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<!--namespace对应mapper接口实体-->
<mapper namespace="com.idcos.automate.dal.mybatis.BibleBookMapper">
    <!--使用resultType来指定返回值信息，由于配置了alias，所以此处可以直接使用类名称-->
    <select id="findAll" resultType="BibleBookDO">
                SELECT * FROM BIBLE_BOOK
        </select>
</mapper>
```

-   扫描启动

``` {.java}
package com.idcos;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ImportResource;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableAutoConfiguration
@EnableScheduling
@ImportResource({ "classpath*:spring/*.xml" })
//mapper所在的包
@MapperScan("com.idcos.automate.dal.mybatis")
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```
