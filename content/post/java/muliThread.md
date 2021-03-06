---

date :  "2017-04-22T23:36:24+08:00" 
title : "Java多线程学习" 
categories : ["技术文章"] 
tags : ["java"] 
toc : true
---

Java多线程
==========

第一章 多线程技能
-----------------

### 线程与进程的区别

-   一个进程的启动是由多个线程所支持的；windows进程管理器当中的第一项都一个进程，每一个进程可以由多个线程组成；每个线程的任务是不同的，互不影响
-   进程之间的数据不可以共享，而线程可以

### 关键句

-   一个进程至少有一个线程在运行
-   代码的执行结果与执行顺序和调用顺序无关（调用随机性）
-   star方法的执行顺序不代表线程的执行顺序
-   Thread类也实现了Runnable接口，所以Thread的构造方法当中也可以传入Threa对象
-   数据和方法若不做设置，会出现线程不安全的情况，导致同一份数据被多个线程操作，通过在run方法前添加synchronized关键字，控制线程的执行队列，如果有其他线程在操作，那么就需要等待其他线程执行完之后当前线程才可以操作，run方法被称做“互斥区”或“临界区”
-   虽然synchronized可以解决数据安全的问题，但如果多个线程都在排队想要操作数据,而存在一个线程在操作，一直没有结束，那么其他所有的线程都必须在排队
-   run与start的区别是：start返回当前线程的名称是被Thread-0线程调用的结果
-   isAlive()方法用于判断线程是否活动；true/false取决于线程是否结束
-   getName()方法用于获取当前线程的名称
-   sleep()方法用于休眠当前线程
-   getId()方法用于获取当前线程的id
-   interrupted()方法与isInterrupted()方法
-   suspend()方法暂停线程，resume()方法恢复线程，但suspend()方法会独占公共变量，将变量永远锁住，并且会导致数据不同步的情况
-   Thread.yield()方法会放弃当前cpu资源，让利给其他资源使用，这样会导致线程执行时间变长
-   Thread.getPriority()方法可以获取线程的优先级，对应的setPriority()可以设置线程的优先级
-   线程的优先级具有以下特点
    -   继承性：两个线程如果是子父关系，那么priority相等
    -   规则性：优先级高的会大部分先执行完
    -   随机性：随机执行各线程，而非根据优先级高的来执行
    -   优先级高的线程执行速度要快于优先级低的
-   isDaemon()判断一个线程是否是daemon线程（守护线程）;如果是守护线程，如果线程都已经结束了，此标志才会被置为false

第二章 对象及变量的并发访问
---------------------------

### 2.1

-   方法内部的变更不存在非线程安全问题
-   synchronized只会锁对象，不会锁方法；即创建多个对象，会产生多个锁；若只创建一个对象，则线程会顺序执行
-   线程A调用obejct对象当中的synchronized方法时，B线程可以调用其他没有被同步的方法；如果B线程调用了其他也被synchronized声明的方法时，也需要排队等待，需要同步执行
-   什么是脏读：因非线程安全取到的被修改过的数据；对于会产生脏读的方法需要添加synchronized
-   什么叫锁重入：当一个synchronized声明的方法内部调用了其他被声明synchronized方法；
-   一个线程遇到异常，它所持有的锁会全部释放
-   同步不具有继承性；即子类的方法若没有被synchronized声明，而父类的方法被声明了，那么调用子类的时候不会排队

### 2.2

-   synchronized的弊端在于，一个方法若处理时间过长，其他线程需要排队很久；解决方法，将方法当中仅需要同步等待执行的代码声明为synchronized(同步代码块)；这样其他线程就可以访问其他没有被同步的代码
-   synchronized(this)间具有同步性，如果在一个对象当中，那么代码块之间是同步的；即不同的线程调用同一对象的不同synchronized(this)声明代码块时会同步执行
-   若synchronized(非this)对象，那么不周的线程操作不同的对象的代码块的时候不是同步，而是异步
-   对于static的synchronized，有一个问题

``` {.java}
package com.pgy.thread.sync;

/**
 * Created by admin on 10/05/2017.
 */
public class staticSyncTest {

    public static void main(String[] args) {
        ThreadA tha = new ThreadA();
        tha.setName("tha");
        tha.start();

        ThreadB thb = new ThreadB();
        thb.setName("thb");
        thb.start();

        ThreadC thc = new ThreadC(new Service());
        thc.setName("thc");
        thc.start();
    }
}

class Service {
    synchronized public static void printA() {
        System.out.println(Thread.currentThread().getName() + "进入printA()");
        try {
            Thread.sleep(3000);

        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println(Thread.currentThread().getName() + "离开printA()");
    }

    synchronized public static void printB() {
        System.out.println(Thread.currentThread().getName() + "进入printB()");
        System.out.println(Thread.currentThread().getName() + "离开printB()");
    }

    synchronized public void printC() {
        System.out.println(Thread.currentThread().getName() + "进入printC()");
        System.out.println(Thread.currentThread().getName() + "离开printC()");
    }

    /**
     * 为什么printC已经添加了synchronized,还是会异步执行
     * tha进入printA()
     * thc进入printC()
     * thc离开printC()
     * tha离开printA()
     * thb进入printB()
     * thb离开printB()
     */

}

class ThreadA extends Thread {

    @Override
    public void run() {
        super.run();
        Service.printA();
    }
}

class ThreadB extends Thread {

    @Override
    public void run() {
        super.run();
        Service.printB();
    }
}

class ThreadC extends Thread {
    private Service service;

    public ThreadC(Service service) {
        this.service = service;
    }

    @Override
    public void run() {
        super.run();
        service.printC();
    }
}
```

-   同步的代码块不能对String作同步；因为String有常量池的缓存功能，即"A"=="A"
    为true；这样会导致如果两个线程操作的String变更是同一值，则程序一直会被最先抢到资源的线程运行；而其他对象类型则不会；
-   同步块可以用来解决不同程序无限等待的问题；即将可以不做同步的代码抽离出来进行处理；将需要的同步代码进行同步处理；或在对象内部new出不同的对象，对这些对象进行同步处理；
-   若一个对象被多个线程所同步，即时属性改变，也还是同步执行

### 2.3 volatile

-   volatile的作用是让变量可以在多个线程当中可见
-   volatile不支持原子性,即变量会被修改，无法做到变量同步
-   线程安全的两方面：原子性和可见性
-   volatile是让线程每次去公共内存当中取值，而不是私有的内存；所以线程拿到的变量值每次都是其他线程修改后最新的；公共内存与私有内存的区别？
-   AtomicInteger的作用：让线程同步操作变量
-   用原子类进行操作的时候需要注意：一个非同步的方法里面调用原子类的同步方法的时候，这时候线程是不安全的，方法体里面还是需要声明为同步

### volatile与synchronized的区别

-   volatile只能声明变量，synchronized可以声明方法和变量
-   volatile比synchronized更加轻量
-   volatile不会导致阻塞，因为只是声明的变量，变更可以在线程当中可见；随意修改

第三章 线程间通信
-----------------

### 3.1 等待/通知机制

-   wait使线程停止运行，notify使停止的线程继续运行
-   wati和notify都需要在同步的代码块当中执行，否则会抛出InterruptedException
-   每个锁的对象都有两个对列，一个是就绪队列，一个是唤醒队列；
-   notify不会立即释放资源，而是需要等到同步方法执行完成之后，才会释放
-   notify唤醒线程是随机的；多次执行notify或调用notifyAll()可以唤醒所有被等待的线程
-   线程处理wait状态的时候，如果调用interrupt方法会抛出InterruptException异常，遇到异常，锁就会被被释放掉
-   wait(long)在一定时间内等待，超过时间自动唤醒
-   通过操作一个类里面的set和get对某个变量进行操作；set和get可以用wait和notify来进行交替处理
-   可以进行一生产多消费、一生产一消费、多生产多消费（操作栈）
-   pipedInputStream、pipedOutputStream、pipedReader、pipedWriter可以进行线程间的管道流操作；操作之前要connect

``` {.java}
package com.pgy.thread.sync;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;

/**
 * 测试线程间通信--字节流
 * Created by admin on 12/05/2017.
 */
public class PipedStreamTest {

    public static void main(String[] args) throws IOException, InterruptedException {

        PipedDataTest pipedDataTest = new PipedDataTest();

        PipedInputStream pipedInputStream = new PipedInputStream();
        PipedOutputStream pipedOutputStream = new PipedOutputStream();

        pipedInputStream.connect(pipedOutputStream);

        PipedThreadRead pipedThreadRead = new PipedThreadRead(pipedInputStream, pipedDataTest);
        PipedThreadWrite pipedThreadWrite = new PipedThreadWrite(pipedOutputStream, pipedDataTest);

        pipedThreadWrite.start();
        pipedThreadRead.start();



    }
}

class PipedThreadRead extends Thread {
    private PipedInputStream pipedInputStream;
    private PipedDataTest    pipedDataTest;

    public PipedThreadRead(PipedInputStream pipedInputStream, PipedDataTest pipedDataTest) {
        this.pipedInputStream = pipedInputStream;
        this.pipedDataTest = pipedDataTest;
    }

    @Override
    public void run() {
        super.run();
        PipedDataTest.readData(pipedInputStream);
    }
}

class PipedThreadWrite extends Thread {
    private PipedOutputStream pipedOutputStream;
    private PipedDataTest     pipedDataTest;

    public PipedThreadWrite(PipedOutputStream pipedOutputStream, PipedDataTest pipedDataTest) {
        this.pipedOutputStream = pipedOutputStream;
        this.pipedDataTest = pipedDataTest;
    }

    @Override
    public void run() {
        super.run();
        PipedDataTest.writeData(pipedOutputStream);
    }
}

class PipedDataTest {

    public static void writeData(PipedOutputStream pipedOutputStream) {
        try {
            System.out.println("start write");
            for (int i = 0; i < 1000; i++) {
                String data = i + "";
                pipedOutputStream.write(data.getBytes());
            }

            System.out.println();
            pipedOutputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public static void readData(PipedInputStream pipedInputStream) {
        try {
            System.out.println("start read");
            byte[] bytes = new byte[20];
            int readLen = pipedInputStream.read(bytes);

            while (readLen > 0) {
                String newData = new String(bytes, 0, readLen);
                System.out.print(newData);
                readLen = pipedInputStream.read(bytes);
            }
            System.out.println();

            pipedInputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}


```

### 3.2 join方法的使用

-   join可以使当前线程阻塞，直到运行结束后才执行下面的逻辑代码
-   join的线程若被interrupt，则会打印出InterruptException异常
-   join(long)与sleep(long)的区别与相同
    -   两者都可以对线程造成一定时间的阻塞
    -   当时间到达后，join会释放锁，而sleep不会释放锁 ？？？？

### 3.3 类ThreadLocal的使用

-   ThreadLocal当中提供每个线程自己绑定的值；static的变量在大家共享的值
-   ThreadLocal的存值和取值是使用了ThreadLocalMap
-   ThreadLocal当中的变量值具有隔离性
-   重写ThreadLocal的initialValue()方法，可以解决ThreadLocal.get()返回Null的问题

### 3.4 InheritableThreadLocal

-   InheritableThreadLocal继续了ThreadLocal；目的是让子线程可以取到父线程当中的值

第四章 Lock的使用
-----------------

### 4.1 Lock的使用

-   使用ReentrantLock，可以在需要同步的代码前使用lock()方法，同步后使用unlock()方法，效果等同于synchronized
-   ReentrantLock.newCondition()方法可以创建出来一个Condition对象；此对象可以使用await()方法使线程进入WAITTING状态；注意，await()之前，必须使用ReentrantLock的lock()方法，否则会有异常
-   Condition当中的signal()方法相当于notify()方法；signalAll()方法相当于notifyAll()方法
-   ReentrantLock的boolean类型构造方法决定是公平锁(true)还是非公平锁(false)

### 4.2 使用ReentrantReadWriteLock类

-   ReentrantLock的方式效率低下，而ReentrantReadWriteLock可以加速代码的运行
-   读写锁一个是读操作相关的锁，称为共享锁；另一个是写操作相关的锁称为排他锁；多个读锁之间不互斥；多个写锁之间是互斥的；这样可以保证读的时候锁是共享的，不会wating，加快代码的运行速度

第五章 定时器Timer
------------------

### 5.1 Timer的使用

-   Timer(true)构造方法将定时器设置为守护线程，运行结束后线程自己结束
-   多个定时器在同时运行的时候，由于定时器是以队列的方式运行的；所以当前面的Timer耗时较长时，后面的任务运行时间就会被延迟
-   Timer的cancel()方法可以取消Timer下面的所有TimerTask;而TimerTask的cancel()只会取消当前的TimerTask；其他的还是正常运行
-   Timer的cancel()若没有取到锁，那么task信息不会被取消；而是正常执行；即Timer若不量static或者加锁的

第六章 单例模式与多线程
-----------------------

-   单例模式分为懒汉（延时加载）和饿汉（立即加载）；饿汉就是getInstance()方法里面取已经实例化的对象；懒汉是若对象没有被实例化，则new出来,而懒汉违背了单例的规则，因为多线程会New出来多个实例
-   在延迟加载的懒汉模式上，将getInstance()方法添加synchronized关键字或添加同步代码块，可以解决多线程当中不是单例的问题，但是需要此种方式效率低下，会导致多线程阻塞
-   使用DCL(double check locking)模式来解决懒汉加载时单例的问题
-   可以将类声明为静态的，并且在类内部当中实例化，这样就可以保证线程是安全的
-   静态内部类可以达到线程安全问题，但是如果遇到序列化对象时，默认运行的方式结果还是多例的，将getInstance()方法放置在readResolve()当中可以解决此问题
-   static代码块在使用类的时候已经实现了；所以可以将new
    Instance()的代码放到static当中，可以保证单例模式的安全性

``` {.java}
public class StaticSingletonTest {
    public static StaticSingletonTest str = null;

    static {
        str = new StaticSingletonTest();
    }

    public static StaticSingletonTest getInstance() {
        return str;
    }

    public static void main(String[] args) {
        StaticSingeltonThread staticSingeltonThread = new StaticSingeltonThread();
        staticSingeltonThread.run();
    }

}

class StaticSingeltonThread extends Thread {
    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            System.out.println(StaticSingletonTest.getInstance().hashCode());
        }
    }
}
```

-   由于enum的构造方法也是静态的，所以可以在一个枚举类当中，实现单例模式，效果同上

第七章 其他总结
---------------

### 线程的状态

-   线程的状态在Thread.state枚举当中;NEW、RUNNABLE、WAITING、BLOCKED、TIMED~WATING~、TERMINATED
-   NEW：线程被实例化后，未执行start方法
-   RUNNABLE:线程运行状态，当一个线程被实例化之后，在线程的内部的状态就是RUNNABLE（包括构造方法）

``` {.java}
class StaticSingeltonThread extends Thread {

    public StaticSingeltonThread() {
        System.out.println("thread的构造方法:" + Thread.currentThread().getState());//RUNNABLE
    }

    @Override
    public void run() {
        System.out.println("thread的run方法" + Thread.currentThread().getState());//RUNNABLE

    }
}
```

-   WAITING:线程操作对象执行了wait()方法之后
-   TIMED~WAITING~:线程执行了sleep后的状态
-   BLOCKED:当线程在等待其他线程释放锁的状态
-   TERMINATED:线程运行结束后的状态

### 线程组

-   线程组的作用是批量管理线程或线程组对象，有效地对线程或线程组对象进行组织
-   jvm当中的根线程组是system,再getParent()就会抛NPE异常

### simpleDataFormat

-   SimpleDataFormat是线程不安全的，因为多个线程使用的simpleDateFormat操作的format格式是不一样的
-   解决办法，将SimpleDateFormat对象的实例化方法放到ThreadLocal当中

### 线程异常处理

-   Thread.setDefaultUncaughtExceptionHandler()方法可以获取线程当中的异常信息
-   TrehadGroup.uncaughtException()方法可以获取线程组当中的异常

其他
----

### Thread与Runnable的区别 - Thread与Runnable的区别在于Runnable的线程的资源可以共享，多个线程可以同时操作一个变量

### 线程的生命周期

1.  创建：new出来一个Thread
2.  就绪：加入到执行队列当中，等待获取cpu资源去执行
3.  运行：获取到了cpu资源，然后去运行线程
4.  阻塞：wait,join,sleep或者其他的操作让线程让出了cpu的资源
5.  终止：线程运行结束或者调用stop方法

### 守护线程

### jstack
