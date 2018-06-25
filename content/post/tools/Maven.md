+++
date = "2017-03-04T22:39:39+08:00" title = "Maven学习" categories = ["技术文章"] tags = ["maven"] toc = true
+++

简介
====

[Maven Document](http://maven.apache.org/guides/index.html)

概念讲述
--------

### 什么是SNAPSHOT

有的版本号当中以SNAPSHOT为后缀，说明此版本为开发状态，不稳定；

### POM

### Profile

-   用户自己的设置: (%USER~HOME~%/.m2/settings.xml)
-   全局设置: (\${maven.home}/conf/settings.xml)
-   &lt;activation&gt;: 当jdk版本为1.3,1.4,1.5的时候触发，支持区间的写法

``` {.xml}
 <activation>
      <jdk>[1.3,1.6)</jdk>
 </activation>
```

使用
====

常用命令
--------

-   这些命令都是一个一个的plugin [Maven
    Plugins](http://maven.apache.org/plugins/index.html) ; mvn
    -h里面不会显示这些plugin
-   每一个plugin都是一个maven工程；
-   mvn idea:idea: 生成idea的工程
-   mvn eclipse:eclipse: 生成eclipse工程
-   mvn clean : 清理工程
-   mvn test/compile: 运行测试、编译工程
-   mvn deploy : 发布至远程仓库
-   mvn install: 发布工程至本地仓库
-   mvn package: 将工程打包，包文件存放于target目录

常用操作
--------

### 上传文件至repository

``` {.shell}
mvn deploy:deploy-file -DgroupId=com.egfbank.iam -DartifactId=yylm-fcs-iam  -Dversion=1.0  -Dpackaging-jar -Dfile=./yylm-fcs-iam-1.0-SNAPSHOT.jar -Durl=http://maven2.idcos.com:8081/repository/thirdparty/ -DrepositoryId=thirdparty
```

-   repositoryId需要在 .m2/setting.xml里面配置名称及用户名和密码
-   若有报错可以使用 mvn -X 进行debug模式

### TODO 如何利用nexus搭建私有镜像库
