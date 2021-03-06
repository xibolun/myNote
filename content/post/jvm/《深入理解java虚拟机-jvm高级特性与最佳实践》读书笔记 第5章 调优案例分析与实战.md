---

date :  "2017-07-07T23:36:24+08:00"

title : "深入理解Java虚拟机--第5章 调优案例分析与实战"

---

# 第5章 调优案例分析与实战

5.1 概述
--------

5.2 案例分析
------------

### 5.2.1 高性能硬件上的程序部署策略

-   如何解决老年代太大? 重启或者定时触发Full GC
-   64位的JDK消耗的内存一般比32位JDK大，这是由于指针膨胀，以及数据类型对齐补白等因素导致
-   64位的JDK的性能测试结果普遍低于32位JDK
-   根据实际情况可以选择对应的垃圾收集器
-   大量的缓存做为集中式部署

### 5.2.2 集群间同步导致的内存溢出

-   内存经常异常，可以先添加 -XX:+HeapDumpOnOutOfMemroyError参数
-   分析dump文件，定位问题的原因

### 5.2.3 堆外内存导致的溢出错误

-   由于Direct Memroy内存不会进入堆当中，它只能等待老年代满了之后Full
    GC，然后清理掉内存的废弃对象，否则就只能等到内存溢出异常，自己回收
-   -XX: MaxDirectMemroySize 调整大小，内存不足时再抛出OOM或OOE异常

### 5.2.4 外部命令导致系统很慢

-   查看CPU资源消耗情况
-   外部shell脚本调用Runtime.getRuntime().exec()方法，频繁调用会导致CPU和内存的负担很重，因为会clone出来一个进程，结束后再关闭掉

### 5.2.7

-   Java的GUI程序当中一般加入 -Dsun.awt.keepWorkingSetOnMinimize=true
    来保证程在恢复最小化时能够立即响应

5.3 实战Eclipse运行速度调优
---------------------------
