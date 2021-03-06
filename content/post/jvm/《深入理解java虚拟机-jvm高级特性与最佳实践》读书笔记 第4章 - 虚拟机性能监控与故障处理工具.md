---

date :  "2017-07-05T23:36:24+08:00"

title : "深入理解Java虚拟机--第4章 虚拟机性能监控与故障处理"

---


第4章 虚拟机性能监控与故障处理
==============================

4.1 概述
--------

-   工具永远都是知识技能的一层包装
-   我的mac的jdk
    PATH为/Library/Java/JavaVirtualMachines/jdk1.7.0~79~.jdk/Contents/Home

4.2 JDK命令行工具
-----------------

  工具名称   作用
---------- ----------------------------------------------------------------------------------------------------------
  jps        JVM Process Status Tool, 显示指定系统内所有的HotSpot虚拟机进程
  jstat      JVM Statistics Monitoring Tool,用于收集HotSpot虚拟机各方面的运行数据
  jinfo      Configuration Info for Java,显示虚拟机的配置信息
  jmap       Memory Map for Java,生成虚拟机的内存转储快照
  jhat       Jvm Heap Dump Brower，用于分析headump文件，它会建立一个HTTP/HTML服务器，让用户可以在浏览器上查看分析结果
  jstack     Stack Trace for Java， 显示虚拟机的线程快照

### 4.2.1 jps: 虚拟机进程监控工具

-   jps -q : 输入LVMID(Local Virtual Machine
    Identifier)，虚拟机执行主类名称以及这些进程的本地虚拟机唯一ID
-   jps -m : 输出虚拟机进程启动时传递给主类main()函数的参数
-   jps -l : 输出主类的全名，如果进程执行的是jar包，输入jar路径
-   jps -v : 输出虚拟机进程启动时jvm参数
-   jus -mlvV: 查看java进程以及启动的参数及路径

``` {.shell}
# ./jps -q
19959
# ./jps -m
19974 Jps -m
# ./jps -l
19904 sun.tools.jps.Jps
# ./jps -v
19919 Jps -Dapplication.home=/usr/java/jdk1.7.0_80 -Xms8m
[root@puppet-master-139 ~]# jps -mlvV
31346 org.apache.catalina.startup.Bootstrap start -Djava.util.logging.config.file=/usr/yunji/tomcat-rbac-davinci/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xdebug -Xrunjdwp:transport=dt_socket,address=9527,suspend=n,server=y -Xms1024m -Xmx1024m -XX:PermSize=128M -XX:MaxNewSize=2048M -XX:MaxPermSize=2048M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/jvmdump/rbac-davinci -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dcatalina.base=/usr/yunji/tomcat-rbac-davinci -Dcatalina.home=/usr/yunji/tomcat-rbac-davinci -Djava.io.tmpdir=/usr/yunji/tomcat-rbac-davinci/temp
133 clojure.main -m puppetlabs.trapperkeeper.main --config /etc/puppetlabs/puppetserver/conf.d -b /etc/puppetlabs/puppetserver/bootstrap.cfg -Xms2g -Xmx2g -XX:MaxPermSize=256m -XX:OnOutOfMemoryError=kill -9 %p -Djava.security.egd=/dev/urandom
31354 org.apache.catalina.startup.Bootstrap start -Djava.util.logging.config.file=/usr/yunji/tomcat-flow-srv/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Xms1024m -Xmx1024m -XX:PermSize=128M -XX:MaxNewSize=2048M -XX:MaxPermSize=2048M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/jvmdump/catalog -Djdk.tls.ephemeralDHKeySize=2048 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources -Dcatalina.base=/usr/yunji/tomcat-flow-srv -Dcatalina.home=/usr/yunji/tomcat-flow-srv -Djava.io.tmpdir=/usr/yunji/tomcat-flow-srv/temp
43 clojure.main -m puppetlabs.puppetdb.main --config /etc/puppetlabs/puppetdb/conf.d -b /etc/puppetlabs/puppetdb/bootstrap.cfg -Xmx192m -XX:OnOutOfMemoryError=kill -9 %p -Djava.security.egd=/dev/urandom
32331 sun.tools.jps.Jps -mlvV -Dapplication.home=/usr/java/jdk1.8.0_144 -Xms8m
```

### 4.2.2 jstat: 虚拟机统计信息监视工具

-   jstat是用于监视虚拟机的各种运行状态信息的命令行工具
-   jstat可以显示本地或远程虚拟机进程中的类装载，内存，垃圾收集，JIT编译等运行数据
-   jstat -class vmId : 查看java进程的类加载信息
-   jstat -gc vmId: 查看java进程的堆状况
-   -gcutil : 输出已使用空间占总空间的百分比
-   -gccapacity : 输出Java堆各个区域使用内存的情况，最大、最小空间
-   -gccause : 输出导致上一次GC的原因
-   -gcnew : 新生代gc
-   -gcnewcapcacity :
-   -gcold : 老年代GC
-   -compiler : JIT编译器编译过的方法、耗时等
-   -printcompilation : 输出已经被JIT编译过的方法

### 4.2.3 jinfo: Java配置信息工具

-   jinfo pid : 查看java进程里面jvm的配置信息

### 4.2.4 jmap: Java内存映像工具

-   jmap: Memory Map for Java，用于生成堆转储快照
-   jmap pid : 查看进程堆快照
-   jmp -heap pid : 查看进程的堆详细信息
-   jmap -dump:format=b,file=/tmp/aa.bin 660 : dump文件

``` {.shell}
# ./jmap 660Attaching to process ID 660, please wait...Debugger attached successfully.
Server compiler detected.
JVM version is 24.80-b11
0x0000000000400000      7K      /usr/java/jdk1.7.0_80/jre/bin/java
0x00007f3d8ef56000      36K     /usr/java/jdk1.7.0_80/jre/lib/amd64/headless/libmawt.so
0x00007f3d8f15d000      755K    /usr/java/jdk1.7.0_80/jre/lib/amd64/libawt.so
0x00007f3d8f9de000      108K    /usr/lib64/libresolv-2.17.so
0x00007f3d8fbf8000      26K     /usr/lib64/libnss_dns-2.17.so
0x00007f3dac8b3000      86K     /usr/lib64/libgcc_s-4.8.5-20150702.so.1
0x00007f3dacacf000      250K    /usr/java/jdk1.7.0_80/jre/lib/amd64/libsunec.so
0x00007f3daceac000      44K     /usr/java/jdk1.7.0_80/jre/lib/amd64/libmanagement.so
0x00007f3dad0e5000      113K    /usr/java/jdk1.7.0_80/jre/lib/amd64/libnet.so
0x00007f3dad2fc000      89K     /usr/java/jdk1.7.0_80/jre/lib/amd64/libnio.so
0x00007f3dadb13000      21K     /usr/java/jdk1.7.0_80/jre/lib/amd64/libdt_socket.so
0x00007f3db16ae000      107K    /usr/java/jdk1.7.0_80/jre/lib/amd64/libzip.so
0x00007f3db18c6000      60K     /usr/lib64/libnss_files-2.17.so
0x00007f3dbc1cc000      14K     /usr/java/jdk1.7.0_80/jre/lib/amd64/libnpt.so
0x00007f3dbc3cf000      264K    /usr/java/jdk1.7.0_80/jre/lib/amd64/libjdwp.so
0x00007f3dbc60a000      214K    /usr/java/jdk1.7.0_80/jre/lib/amd64/libjava.so
0x00007f3dbc835000      63K     /usr/java/jdk1.7.0_80/jre/lib/amd64/libverify.so
0x00007f3dbca43000      43K     /usr/lib64/librt-2.17.so
0x00007f3dbcc4b000      1114K   /usr/lib64/libm-2.17.so
0x00007f3dbcf4d000      14879K  /usr/java/jdk1.7.0_80/jre/lib/amd64/server/libjvm.so
0x00007f3dbddc7000      2058K   /usr/lib64/libc-2.17.so
0x00007f3dbe188000      19K     /usr/lib64/libdl-2.17.so
0x00007f3dbe38c000      96K     /usr/java/jdk1.7.0_80/jre/lib/amd64/jli/libjli.so
0x00007f3dbe5a1000      138K    /usr/lib64/libpthread-2.17.so
0x00007f3dbe7bd000      160K    /usr/lib64/ld-2.17.so

# ./jmap -heap 660
Attaching to process ID 660, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 24.80-b11

using thread-local object allocation.
Mark Sweep Compact GC                     ## CMS垃圾回收器

Heap Usage:                               ## 各区域堆的使用情况
New Generation (Eden + 1 Survivor Space):
   capacity = 161021952 (153.5625MB)
   used     = 101349832 (96.65473175048828MB)
   free     = 59672120 (56.90776824951172MB)
   62.94162425754222% used
Eden Space:
   capacity = 143130624 (136.5MB)
   used     = 98631840 (94.06265258789062MB)
   free     = 44498784 (42.437347412109375MB)
   68.91036819625687% used
From Space:
   capacity = 17891328 (17.0625MB)
   used     = 2717992 (2.5920791625976562MB)
   free     = 15173336 (14.470420837402344MB)
   15.191672747825091% used
To Space:
   capacity = 17891328 (17.0625MB)
   used     = 0 (0.0MB)
   free     = 17891328 (17.0625MB)
   0.0% used
tenured generation:
   capacity = 357957632 (341.375MB)
   used     = 283893288 (270.74173736572266MB)
   free     = 74064344 (70.63326263427734MB)
   79.3091870716141% used
Perm Generation:
   capacity = 134217728 (128.0MB)
   used     = 71081288 (67.78839874267578MB)
   free     = 63136440 (60.21160125732422MB)
   52.959686517715454% used



```

### 4.2.5 jhat: 虚拟机堆转快照分析工具

-   jhat: JVM Heap Analysis Tool
-   分析是一个比较耗时而且消耗硬件资源的过程
-   jhat的分析比较丑陋，还不如使用VisualVM
-   jhat针对于dump文件进行分析

### 4.2.6 jstack: Java堆栈追踪工具

-   jstack: Stack Trace for Java;
    用于生成虚拟机当前时刻的线程快照信息，即每一个线程在正在执行的方法堆栈的集合
-   可以定位线程的出现长时间卡顿的原因，线程卡顿的时候后台在做什么操作，需要等待的资源
-   jstack -F vmId : 强行输出堆栈信息
-   jstack -l vmId : 显示堆栈信息和锁信息
-   jstack -m vmId : 显示C/C++堆栈信息，若调用本地方法的话

### 4.2.7 HSDIS: JIT生成代码反汇编

-   JIT代码的反汇编插件

4.3 JDK可视化工具
-----------------

-   JDK中提供了JConsole和VisualVM两个可视化工具
-   JConsole是JDK1.5时提供
-   VisualVM是JDK1.6Update7版本提供

### 4.3.1 JConsole

-   JConsole可以通过remote连接运行服务器

### 4.3.2 VisualVM

-   visualVM可以安装插件


#### 定位java慢的问题

1. top ,然后 shift + h ，看线程，观察哪个线程异常记录下pid
2. jstack $java主进程pid > a.log  打出线程到文件
3. printf '0x%x\n'  异常线程pid转为16进制
4. 打开a.log搜0x625c 看线程堆栈定位问题。