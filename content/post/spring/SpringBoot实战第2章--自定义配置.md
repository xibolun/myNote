+++
date = "2017-09-20T23:36:24+08:00"
title = "SpringBoot实战第2章--自定义配置"

+++

注解
----

属性文件外置配置
----------------

-   要想使用属性文件外置配置，根据 [Generating your own meta-data using
    the annotation
    processor](https://docs.spring.io/spring-boot/docs/1.5.7.RELEASE/reference/html/configuration-metadata.html#configuration-metadata-annotation-processor)
    需要配置spring-boot-configuration-processor依赖

``` {.xml}
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

-   配置properties文件

``` {.txt}
amazon.accountId=pengganyu
```

-   PropertyConfig信息，需要添加@ConfigurationProperties注解

``` {.java}
package com.idcos.automate.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "amazon")
public class PropertyConfig {

    private String accountId;

    public String getAccountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }
}
```
