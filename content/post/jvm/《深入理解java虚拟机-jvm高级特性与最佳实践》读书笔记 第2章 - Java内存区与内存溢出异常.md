+++
date = "2017-06-28T23:36:24+08:00"
title = "深入理解Java虚拟机--第2章 Java内存区域与内存溢出异常"

+++


第2章 Java内存区域与内存溢出异常
================================

### 2.1 概述

C语言的内存管理是由开发者自行操作的，所以当开发者经验不足的时候就会写出内存溢出的代码；而java的内存则由虚拟机进行管理，开发人员不用担心内存回收和使用的问题；但是当内存溢出的时候，如果不懂得jvm是怎么操作内存的，排查问题就会比较麻烦

### 2.2 运行时数据区域

-   虚拟机栈
-   本地方法栈
-   方法区
-   堆
-   程序计数器

#### 2.2.1 程序计数器

-   程序计数器是一块小的区域，每一个线程都有独立的程序计数器，保证线程在切换的时候可以恢复到正确的执行位置；字节码解释器就是通过改变程序计数器来执行for、while、swtich等表达式;

#### 2.2.2 java虚拟机栈

-   java虚拟机栈是线程私有的，生命周期与线程相同,每个方法在创建使用的时候都会创建一个栈帧，方法的调用对应着方法所对应的栈帧从入栈到出栈的过程
-   虚拟机栈局部变量表存放着java的基础数据类型，对象引用和returnAddress类型，其中long和double占用了两个slot
-   若线程请求的栈的深度大于虚拟机所允许的深度，抛StackOverflowError
-   若线程请求的内存大小超出了可以申请的内存，抛OutOfMemoryError

#### 2.2.3 本地方法栈

-   本地方法栈为线程找到本地的Native方法，虚拟机栈为线程使用java服务
-   本地方法栈同虚拟机栈一样会抛出两个异常

#### 2.2.4 java堆（java Heap）

-   堆是内存当中管理最大的一块，堆里面的内存供线程共享
-   堆内存由虚拟机启动时创建，存放对象实例、数组
-   java堆可以处于物理上面内存不连续，扩展一般通过Xmx和Xms来控制

#### 2.2.5 方法区

-   方法区的内存同堆内存一样，供线程共享
-   存放着已经被虚拟机加载的类、常量、静态变量、即时编译后的代码数据
-   当方法区无法满足线程所申请的内存时，抛出OOM异常

#### 2.2.6 运行时常量池（Runtime Constant Pool）

-   用于存放类当中的常量信息
-   常量池属于方法区的一部分

#### 2.2.7 直接内存（Direct Memory）

-   直接内存不是运行时数据区域，也不是java虚拟机里面定义的内存，但是可以将一些数据信息放到直接内存当中，避免在堆内存和方法区当中来回复制，以提高效率
-   若服务器物理内存不足时，会抛出OOM异常

### 2.3 HotSpot虚拟机对象探秘

#### 2.3.1 对象创建

-   对象创建的步骤是什么？虚拟机遇到new关键字，检查常量池当中是否存在类的引用，并检查此类是否加载，初始化等；若没有加载，则会走类加载的流程；若已经加载，则进入堆内存的分配；若堆内存是规整的，则使用指针碰撞的方式进行分配，若不规整，则根据虚拟机记录的空闲列表进行分配
-   如何保证对象在多个线程创建的时候是不会重复的？对象在创建的时候，每个线程会在堆内存当中预先分配一小段内存叫做本地线程分配缓冲区（Thread
    Local Allocation Buffer
    TLAB）当TLAB分配完的时候才会进行同步创建堆内存的处理；另一种方式是直接同步进行创建

#### 2.3.2 对象内存布局

-   对象在内存当中存储的部局有3块区域：对象头（Header）、实例数据（Instance
    Data）和对齐填充（Padding）
-   对象头里面包括两部分：第一部分用于存储对象自身的运行时数据，如hashCode，GC分代年龄，锁状态标志，线程持有的锁、偏向线程ID、偏向时间戳等，这些数据被称为Mark
    Word，长度为32bit或64bit；如果是数组还需要一块记录数据长度的区域；

  存储内容                               标志位   状态
-------------------------------------- -------- --------------------
  对象hashCode，对象分代年龄             01       未锁定
  指向锁记录的指针                       00       轻量级锁定
  指向重量级锁的指针                     10       膨胀（重量级锁定）
  空，不需要记录信息                     11       GC标记
  偏向线程ID，偏向时间戳，对象分代年龄   01       可偏向

-   HotSpot虚拟机默认分配策略为：longs/doubles、ints、shorts/chars、bytes/booleans、oops，相同宽度的字段总是被分配到一起
-   HotSpot VM的自动内存管理系统要求对象起始地址必须是8字节的整数倍

#### 2.3.3 对象的访问定位

-   目前对象的访问方式主流的有两种，一种是使用句柄，另一种是直接指针
-   句柄访问：reference数据存放于栈当中，但栈当中实际存储的是对象的句柄地址，句柄地址实际上是放在堆内存当中，它包含着对象实例数据与类型数据各自的地址信息；因为如果使用句柄进行访问，那么堆当中会划分出一块内存做为句柄池
-   直接指针：如果为直接指针，那么栈当中的reference存放的就是实际的对象地址
-   两者之间的区别：句柄访问的时候，如果对象的实际指针发生变化，只会修改句柄地址指向的指针信息，不会影响reference当中的地址，更加稳定；而使用直接指针的方式就是速度更快，因为不需要通过句柄地址去找对象实际的指针地址，节省再次定位实际对象指针的时间开销；

### 2.4 实战OOM异常

-   为什么说程序计数器不会发生OOM异常:此处基本没有内存开销，主要是操作一些语法表达式，对当前线程进行添加flag操作

#### 2.4.1 Java堆溢出

-   jvm启动内存参数指定：Xms:堆的最小值，Xmx:堆的最大值
-   当发生OOM异常的时候，第一步需要根据内存映射分析工具（MAT）进行分析，首先判断是内存泄漏还是内存溢出；如果不是内存泄露，那么可以将jvm启动参数适当调大；
-   如果是内存泄露，可以通过泄露工具进行查看GC
    Roots的引用链，找到为什么垃圾回收无法回收此泄露对象

#### 2.4.2 虚拟机栈和本地方法栈溢出

-   HotSpot不区分虚拟机栈和本地方法栈，所以参数-Xoss是无效的，只有-Xss是有效的

``` {.java}
/**
 * Xss参数测试OOM异常与SOE异常
 *
 *  -Xss160k
 * Created by admin on 19/06/2017.
 */
public class XssOOM {
    static int i = 0;

    public static void count() {
        i++;
        count();
    }

    public static void main(String[] args) {

        System.out.println("Total Memroy: " + Runtime.getRuntime().totalMemory() / 1024 / 1024);
        System.out.println("Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024);
        System.out.println("Free Memroy: " + Runtime.getRuntime().freeMemory() / 1024 / 1024);

        try {
            count();
        } catch (Throwable e) {
            /**
             * Total Memroy: 123
             * Max Memory: 1820
             * Free Memroy: 117
             * i值为:825,操作异常:java.lang.StackOverflowError
             */
            System.out.println("i值为:" + i + ",操作异常:" + e);
        }
    }
}

/**
 * Xss参数测试OOM异常
 * 
 * -Xss2M
 * Created by admin on 19/06/2017.
 */
public class XssOOM {

    public static void stopThread() {
        while (true) {

        }
    }

    public static void threadNew() {
        while (true) {
            Thread thread = new Thread(new Runnable() {
                @Override
                public void run() {
                    stopThread();
                }
            });
            thread.start();
        }
    }

    public static void main(String[] args) {
        System.out.println("Total Memroy: " + Runtime.getRuntime().totalMemory() / 1024 / 1024);
        System.out.println("Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024);
        System.out.println("Free Memroy: " + Runtime.getRuntime().freeMemory() / 1024 / 1024);

        XssOOM xssOOM = new XssOOM();
        xssOOM.threadNew();

    }
}
```

#### 2.4.3 方法区和运行时常量池的溢出

-   异常信息为：java.lang.OutOfMemoryError: PermGen space
-   通过XX参数来进行控制 -XX:PermSize=10M -XX:MaxPermSize=10M
-   运行时常量池属于内存当中的永久代

#### 2.4.4 本地内存溢出

-   异常信息为：java.lang.OutOfMemoryError: PermGen space
-   通过 -XX:MaxDirectMemorySize=2M
    来指定直接内存大小的最大值，若不设定，则指与-Xmx的值一样

