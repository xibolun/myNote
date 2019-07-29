---
date :  "2017-05-23T23:36:24+08:00"
title : "Java核心技术卷一"
categories : ["技术文章"] 
tags : ["java"] 
toc : true
---


Java核心技术--卷I
=================

第1章 Java程序设计概述
----------------------

### java发展史

-   1996年sun公司发布java 1.0版本
-   1998年在JavaOne大会上发布java 2.0版本
-   2004年在JavaOne会议上发布5.0版本
-   2006年年末发布6.0版本
-   2009年sun公司被收购
-   2011年oracle发布1.7版本
-   2013年oracle发布1.8版本

第2章 Java程序设计环境
----------------------

第3章 Java的基本程序设计结构
----------------------------

### 数据类型

  类型      存储需求      取值范围
--------- ------------- ------------
  int       4字节         &gt;20亿
  short     2字节         
  long      8字节         
  byte      1字节         -128\~127
  float     4字节         
  double    8字节         
  boolean                 false/true
  char      unicode编码   

-   前缀0x:16进制
-   前缀0:8进制
-   前缀0b:二进制
-   数字字面量可以加下划线：1~000000表示1百万~

### 位运算

-   &
-   

-   \^
-   \~
-   &gt;&gt;:右移
-   &lt;&lt;:左移

### 字符串

由于在虚拟机当中相同的字符串是共享的，理论上可以使用==来判断两个字符串的值是否相等；实际上只有字符串常量是共享的，而+或substring等操作产生的结果是不共享的

第4章 对象与类
--------------

### 面向对象程序设计（OOP-Object Oriented Programming）

### 对象的三个特性

-   对象的行为（behavior）
-   对象的状态(state)
-   对象标识(identity)

### 表达类关系之间有UML符号

-   继承
-   接口实现
-   依赖
-   聚合
-   关联
-   直接关联

第5章 继承
----------

-   被final声明的类，不允许被继承，类中的方法也为final的，java当中的String就是final的；Calendar当中的setTime()和getTime()也是final的
-   被final声明的类可以在不使用动态绑定，节省系统的开销；
-   抽象类不能被实例化，只能实例化它的子类
-   hashCode()与equals()的返回值是相同的
-   方法当中的入参为 objedct...这种形式叫做 参数可变

### 继承的设计技巧

1.  将公共操作和属性放在父类当中
2.  不要使用受保护的属性
3.  使用继承实现"is-a"的关系
4.  除非所有的继承方法都有意义，否则不要放到父类当中
5.  覆写方法的时候，不要改变预期的行为
6.  使用多态，而不是instanceOf的判断
7.  不要过多使用反射

第6章 接口与内部类
------------------

### 接口

-   接口不是类，但是定义了对类的需求描述，类必须实现接口里面的方法定义
-   接口不是类，所以无法实例化
-   接口与抽象类的区别；java里面只支持单继承，接口则可以被多实现；

### 深度clone

-   由于每个的父类都是object，而object当中有clone的方法；所以每个类都可以使用clone方法；但结果就是浅clone；即无法拷贝类内部的对象
-   如果一个类想要重写clone方法，就必须实现Cloneable接口，同时定义public的clone方法，并实现clone方法

### 内部类

-   内部类的好处：访问控制和隐式调用
-   显式内部类：在实例化对象的时候将对象里面的方法进行实现

第11章 异常、断言、日志和调试
-----------------------------

-   java异常都是继承于Throwable；分为error和exception;而exception又分为派生RuntimeException和其他异常
-   派生异常RuntimeException包括：错误类型转换、数组访问越界、空指针
-   非派生异常包括：试图在文件结尾处读取数据、试图打开一个不存在的文件、找不到类等
-   断言: assert 条件：表达式
-   断言的启用和禁用：java -ea或java -enableassertions xxx
-   LOG日志记录7个级别：SERVER||WARNING||INFO||CONFIG||FINE||FINER|FINEST
-   使用ResourceBundle可以对日志进行本地化处理，但是需要在配置en~properties和zhproperties等不同语言的配置文件~
-   11.6调试技巧一节当中介绍了javac的一些命令和其他的一些特点

第12章 泛型程序设计
-------------------

-   泛型不能使用基础数据类型如：double,int等，只能使用Double、Integer
-   无法创建泛型参数的数组；即无法 new
    Pair&lt;String&gt;\[10\];如果将10去掉也是语法正确
-   不能实例化泛型变量，即new T()是错误的
-   泛型无法用static声明
-   通配符?，解决泛型之间的调用问题

第13章 集合
-----------

### 未完成

-   散列集的add和树集的add有什么算法区别，哪个更快？
-   链表和数组列表有什么区别，在使用上面哪个更好？
-   Vector里面的一些方法是同步的，在执行的时候效率会比ArrayList低;所以一般都使用ArrayList
-   LinkedList可以快速进行数据的增加和删除，但是在get和set的时候就必须去遍历，虽然get方法做了优化，当index&gt;
    size&gt;&gt;1时，会从list的尾部开始查询
-   PriorityQueue是怎么完成排序的

### 链表

### 数组列表

### 散列集

-   散列集为每个元素计算一个hasCode（散列码）；add一个对象的时候，计算对象的hashCode，和散列表的size进行取余运算，得出的结果就是此对象的位置；
-   treeSet对元素进行排序后输出
-   linkedHashSet记录元素的添加顺序

### 树集

-   树集的数据结构彩红黑树；迭代器以排好序的顺序访问每个元素；比散列表要慢，因为散列表是不排序的

### 对象比较

-   接口Comparable当中的compareTo()，若两个对象a与b相等返回0，a在于b前面，返回负值；a位于b之后返回正值;String当中的compareTo方法是按字典顺序进行比较

``` {.java}
public int compareTo(String anotherString) {
        int len1 = value.length;
        int len2 = anotherString.value.length;
        int lim = Math.min(len1, len2);
        char v1[] = value;
        char v2[] = anotherString.value;

        int k = 0;
        while (k < lim) {
            char c1 = v1[k];
            char c2 = v2[k];
            if (c1 != c2) {
                return c1 - c2;
            }
            k++;
        }
        return len1 - len2;
    }
```

### 队列与双端队列

-   queue的
    add和offer方法区别，如果队列满了，add会抛出异常，offer返回false
-   queue的
    remove和poll方法区别，如果队列空，remove会抛出异常，poll会返回null
-   queue的
    element和peek方法区别，如果队列为空，element会抛出异常，peek会返回null
-   Deque为双端对列，只能在队列的两端进行操作，不能在中间操作;实现了pop()和push()相关操作的方法,
    addFirset,addLast,pollFirst，pollLast等这是queue没有的方法
-   Deque的pop方法移除队列当中第一个元素，push将元素放在第一个；FIFO原则

### 优先级队列

-   PriorityQueue是一个类；内部实现的是二叉树的heap数据结构，将最小的元素放在根部，保证排序

### 映射表

-   映射表就是Map,包括HashMap和TreeMap
-   Map的put方法返回一个value信息，如果key已经有value，则将oldValue返回
-   Map的keySet不是HashSet，也不是TreeSet
-   Map的entrySet返回是键值对信息；可以删除，但不能新增元素
-   Map当中的key可以为空
-   IdentityHashMap当中的键值列不是以hashCode来计算，而是以(System.identityHashCode来计算，对象之间的比较需要用==而不是equals

### Collections

-   synchronizedMap(Map&lt;K,V&gt; m)获取同步线程执行的map对象
-   unmodifiableMap(Map&lt;? extends K,? extends V&gt; m)
    获取不可修改的map对象
-   checkedList(List&lt;E&gt; list, Class&lt;E&gt; type)
    检查对象是否全规，是否存在转换异常等
-   binarySearch(List&lt;? extends Comparable&lt;? super T&gt;&gt; list,
    T key)
    集合当中的二分法查找，前提List是一个排序好的集合；若返回值&gt;0，说明匹配到了元素；返回负值i，是元素应该在的地方，保证数组的有序；-i-1;

### 遗留的集合

-   Hashtable：同步的HashMap
-   Enumeration：hashMoreElements和nextElement

### 属性映射表Properties

key和value都是String类型的

### 栈Stack

-   push和pop方法
-   peek
-   empty
-   search返回object所在的index

### 位集BitSet

-   and
-   or
-   xor
-   andNot
-   clear

第14章 多线程
-------------

### 守护线程

-   守护线程不应该操作固有的资源，文件、数据库等，因为当没有其他线程在使用的时候，守护线程会自动关闭
-   Thread当中守护线程的最大priority为7，最小为1，Normal为5；此数据会随着操作系统的变化而变化

### 为什么不使用stop和suspend方法

-   stop无法保证对象的安全，当一个对象调用了方法之后，无法知道什么时候可以让线程stop掉，因为你不知道对象的方法是否执行结束
-   suspend方法挂起一个持有锁的对象的线程的时候，那么此锁在恢复之前不可用，其他线程一直在等待，这样容易造成死锁

### 阻塞队列

-   阻塞队列是一个非常好的处理线程阻塞的方法，使用队列一个线程可以安全的将数据传递给另外一个，其他线程将数据取出，修改完之后再塞入队列
-   常用的队列有ArrayQueue,LinkedBlockingQueue,DelayQueue,PriorityBlockingQueue,BlockingQueue,transferQueue;

### 线程安全的集合

#### 高效的映射表、集合、队列
