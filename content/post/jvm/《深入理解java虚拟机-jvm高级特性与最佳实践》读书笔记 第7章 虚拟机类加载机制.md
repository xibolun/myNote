---

date :  "2017-07-10T23:36:24+08:00"

title : "深入理解Java虚拟机--第7章 虚拟机类加载机制"

---

第7章 虚拟机类加载机制
======================

7.1 概述
--------

-   jvm是怎么加载这些Class文件信息的？
-   Class文件进入jvm会发生什么变化？
-   jvm把类的数据从Class文件添加到内存，并对数据进行校验，转换解析和初始化，最终形成可以被jvm直接使用的java类型，这就是jvm的类加载机制
-   类型的加载、连接和初始化都是在运行期间完成的，这样做可以动态扩展，但会开销一些性能问题

7.2 类加载时机
--------------

-   类的生命周期
    加载(loading)、验证(Verification)、准备(Preparation)、解析(Resolution)、初始化(Initialization)、使用(Using)、卸载(Unloading)七个阶段。
-   其中验证、准备、解析统称为连接，解析有可能在初始化的时候才开始
-   什么时候开始初始化：1)遇到new、getstatic、putstatic或invokestatic这4条字节码指令
    2)使用reflect包的方法对类进行反射调用时 3)父类没有初始化
    4)需要执行含有main方法主类 5)MethodHandle实例所调用的类

``` {.java}
public class SuperClassLoad {
    static int value = 1000;

    static {
        System.out.println("SuperClass init!");
    }
}

class SubClass extends SuperClassLoad {
    static {
        System.out.println("SubClass init!");
    }
}

class mainTest {
    public static void main(String[] args) {
        /**
         * 没有使用SubClass当中的属性,所以不会被加载,不会输出SubClass init
         * SuperClass init!
         * 1000
         */
        System.out.println(SubClass.value);
    }
}
```

``` {.java}
public class ConstantLoad {
    public static final String CODE = "Java";

    static {
        System.out.println("ConstantLoad init!");
    }
}

class ConstantRef {
    public static void main(String[] args) {
        /**
         * 不会输出Constant init,因为CODE被放在了常量池当中
         */
        System.out.println(ConstantLoad.CODE);
    }
}

```

-   接口也有初始化，接口当中不能使用static{}语句块，但编译器仍然会为接口生成构造方法用于初始化接口当中的成员变量，并且只有使用到了父接口的时候才会初始化其父接口

7.3 类加载过程
--------------

### 7.3.1 加载

-   加载阶段，虚拟机完成3件事情：
-   1.  通过一个类的全限定名来获取定义此类的二进制字节流
-   1.  将此字节流所代码的静态存储结构转化为方法区的运行时数据结构
-   1.  内存中生成一个代表这个类的java.lang.Class对象，作为方法区这个类的各种数据访问入口
-   数组类不能通过类加载器创建，是由jvm直接创建的
-   连接阶段与加载可以是交叉进行的

### 7.3.2 验证

-   验证Class文件的字节流包含的信息是符合jvm的要求，并且不会危害jvm自身的安全
-   验证不是一定必须的，但非常重要

#### jvm检验的动作

-   文件格式，是否以魔数cafebase开头，主次版本号的大小是合规，常量池里面有没有不支持的类型等
-   元数据验证：对字节码的语义分析，比如是否有父类，是否继承了final的父类等
-   字节码验证：最复杂的阶段，通过数据流和控制流确定程序是合法，符合逻辑
-   符号引用验证：声明的字符串是否可以被当前类进行访问等，作用是保证解析动作可以正常执行

### 7.3.3 准备

-   为类变量分配内存并设置类变量的初始值的阶段，会将static声明的基础数据类型初始化零值
-   实际的值是putstatic指令编译后放在类构造器方法当中的
-   若变量被final生成，则准备阶段将对应的value直接赋值

### 7.3.4 解析

-   解析阶段是jvm将常量池内的符号引用替换为直接引用的过程
-   符号引用：以一组符号来描述所引用的目标
-   直接引用：直接指向目标指针、相对偏移量或是一个能间接定位到目标的句柄
-   同一个符号引用可能会多次解析请求
-   解析动作主要针对类或接口、字段、类方法、接口方法、方法类型、方法句柄和方法点限定符

### 7.3.5 初始化

-   初始化是真正开始执行类定义的Java程序代码（字节码）
-   真正给初始化变量和其他资源赋非零值，即执行&lt;clinit&gt;的过程
-   &lt;clinit&gt;是怎么产生的？编译器自动收集类中的所有类变量的赋值动作和静态语句块中的语句合并产生的

7.4 类加载器
------------

-   类加载器用于类层次划分、OSGi、热部署、代码加密等领域

### 7.4.1 类与类加载器

-   通过类加载器加载的类在jvm里面保证唯一性，不同的jvm的类加载器加载的相同的类文件是不相等的，相等就是equals、isInstance等方法返回的值是相同的

### 7.4.2 双亲委派模型

-   jvm有两种不同的类加载器：启动类加载器(Bootstrp
    ClassLoader)，由C++实现，是jvm的一部分；另一种就是所有其他的类加载，都由Java语言实现，不属于jvm，都继承于java.lang.ClassLoader
-   启动类加载器(Boostrap
    ClassLoader):类加载器存放于lib中或者被-Xbootclasspath参数指定的路径中，并且是被虚拟机识别的如rt.jar，lib目录下面的名称如果不符合也不会被加载，类加载器无法被java程序直接调用
-   扩展类加载器(Extension ClassLoader):
    此加载器由sun.misc.Launcher\$ExtClassLoader实现，负责加载lib\ext或者被java.ext.dirs系统变量所指定的路径中的所有类库中，可以被开发者直接使用
-   应用程序类加载器(Application ClassLoader):
    由sun.misc.Launcher\$AppClassLoader实现，由ClassLoader当中的getSystemClassLoader()方法返回，负载加载用户类路径上所指定的类库
-   自定义类加载器：最底层的加载器，是用户自己可以录入的
-   什么是双亲委派：除了顶层的启动类加载器，其他的类加载器都要有自己的父类加载器，类加载器之间的父子关系一般不会以继承的关系来实现，都是以组合的关系来利用父加载器的代码
-   在双亲委派的工作模型当中，一个类加载器收到类加载请求，自己不会尝试加载，而是去委派给父类加载完成，只有当父类无法完成的时候，子加载器也会尝试自己加载
-   双亲委派的好处就是Java类随着它的类加载器有了优先级的层次，java.lang.Object存放的rt.jar当中
-   类加载器的代码在java.lang.ClassLoader的loadClass方法

### 7.4.3 破坏双亲委派模型

-   JDK1.0的历史原因，JDK1.2需要做兼容处理
-   基础类无法调用用户的代码
-   如何做到Hotswap和HostDeployment

