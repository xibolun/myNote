---
date :  "2017-06-03T23:36:24+08:00"
title :  "Java核心技术卷二"
categories : ["技术文章"] 
tags : ["java"] 
toc : true
---

Java核心技术卷二
================

第3章 网络编程
--------------

### socket

-   socket(String host,String port):获取一个套接字
-   socket.getInputStream(): 获取流的数据信息
-   socket.setTimeout(1000): 设置socket连接超时时间
-   socket.isConnect():
-   socket.shutdownOutPut():
    半关闭，客户端向服务器端发送完数据之后就关闭套接字
-   socket.isInputShutdown()): 测试Input是否shutdown
-   socket.isOutputShutdown()): 校验outPut是否shutdown

### ServerSocket

### SocketChannel

### URL

第5章 国际化
------------

第8章 JavaBean构件
------------------

第9章 安全
----------

### Java提供三种安全机制

-   语言设计特性（对数组边界进行检查，无不受检查的类型转换，无指针算法等）
-   访问控制机制，用于控制代码能够执行操作（文件访问，网络访问）
-   代码签名，作者可以使用标准的加密算法来认证java代码，准备知道代码被谁创建，被谁修改

### 类加载器

#### Java程序的三个类加载器

-   引导类加载器：通常从rt.jar当中进行加载，是虚拟机不可缺少的部分
-   扩展类加载器：项目或工程当中引入的jar包
-   系统类加载器：环境变量所配置的jre当中的类

