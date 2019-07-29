---
date :  "2017-06-22T23:36:24+08:00" 
title : "Java基础" 
categories : ["技术文章"] 
tags : ["java"]
---

一些颠覆认知的问题
------------------

### Java的String地址是相等的

``` {.java}
        System.out.println("a" == "a");   //true
        System.out.println("a".equals("a"));  //true
```

### Integer的valueOf存在默认值-127\~127的区间

``` {.java}
        Integer f1 = 100, f2 = 100, f3 = 150, f4 = 150;

        System.out.println(f1 == f2);// true
        System.out.println(f3 == f4);// false
```

### switch case在处理String的时候，比对的是String的hashCode

``` {.java}
public class Test {
    public Test() {
    }
    public static void main(String[] args) {
        String str = "test";
        byte var3 = -1;
        switch(str.hashCode()) {
        case 97:
            if(str.equals("a")) {
                var3 = 0;
            }
            break;
        case 98:
            if(str.equals("b")) {
                var3 = 1;
            }
            break;
        case 99:
            if(str.equals("c")) {
                var3 = 2;
            }
        }
        switch(var3) {
        case 0:
            System.out.println("a");
            break;
        case 1:
            System.out.println("b");
            break;
        case 2:
            System.out.println("c");
            break;
        default:
            System.out.println("c");
        }
    }
}
// 编译后的代码
public class Test {
    public Test() {
    }
    public static void main(String[] args) {
        String str = "test";
        byte var3 = -1;
        switch(str.hashCode()) {
        case 97:
            if(str.equals("a")) {
                var3 = 0;
            }
            break;
        case 98:
            if(str.equals("b")) {
                var3 = 1;
            }
            break;
        case 99:
            if(str.equals("c")) {
                var3 = 2;
            }
        }
        switch(var3) {
        case 0:
            System.out.println("a");
            break;
        case 1:
            System.out.println("b");
            break;
        case 2:
            System.out.println("c");
            break;
        default:
            System.out.println("c");
        }
    }
}

```

名称解释
--------

### PO/DTO/VO等

-   PO: persitant object
-   VO: value object
-   DO: domain object（领域对象）
-   TO: transfer object
-   BO: business object
-   POJO: plain ordinary java object（简单无规则java对象）
-   DAO: data access object （数据库访问对象）
-   DTO: data transfer object （数据传输对象）

### JVM Options

-   [Java HotSpot VM
    Options](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)

