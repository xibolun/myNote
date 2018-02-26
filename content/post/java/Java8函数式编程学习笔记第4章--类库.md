+++
date = "2017-10-10T23:36:24+08:00"
title =  "Java8函数式编程笔记第4章"

+++


第4章 类库
----------

### 数据类型

-   int占用4字节，Integer占用16字节;Integer为整形对象
-   在最坏的情况下，Integer\[\]要比int\[\]多占用6倍的内存
-   所以拆箱效率比装箱快

``` {.java}
    public static void mapToFun() {
        System.out.println(Stream.of(new Integer(20)).mapToInt(x -> x.intValue()).count());
        System.out.println(Stream.of(new Integer(20)).mapToLong(x -> x.longValue()).count());
        System.out.println(Stream.of(new Integer(20)).mapToDouble(x -> x.doubleValue()).count());
    }

    public static void intStream() {

        System.out.println(IntStream.of(1, 2, 3).average().getAsDouble());
        System.out.println(IntStream.of(1, 2, 3).max().getAsInt());
        System.out.println(IntStream.of(1, 2, 3).min().getAsInt());
        System.out.println(IntStream.of(1, 2, 3).findFirst().getAsInt());
        System.out.println(IntStream.of(1, 2, 3).findAny().getAsInt());
        System.out.println(IntStream.of(1, 2, 3).count());
        System.out.println(IntStream.of(1, 2, 3).sum());
        System.out.println(IntStream.of(1, 2, 3).limit(2).findFirst().getAsInt());
        IntStream.range(1, 10).forEach(x -> System.out.println(x));

    }
```

### Optional

``` {.java}
    public static void OptionalTest() {
        System.out.println(Optional.of("ab").get());
        //        System.out.println(Optional.of(null).get());//NPE
        System.out.println(Optional.ofNullable(null).orElse("bb"));
        System.out.println(Optional.empty().orElse("bb"));
        System.out.println(Optional.of("aa").orElse("bb"));
    }
```

### 重载解析

-   用lambda做为参数传递的时候遵守以下原则
-   若只有一个可能的目标类型，由相应的函数接口的参数类型推导得出
-   若有多个可能的目标类型，由相应的函数接口参数类型推导得出
-   若有多个可能的目标类型且最具体的目标类型不明确的时候，需要人为进行指定lambda的参数类型

### default

``` {.java}

interface Parent {

    public default void welcome() {
        System.out.println("this is parent");
    }
}

class ParentImpl implements Parent {

}

```

-   使用default定义的接口方法不需要子类必须实现
-   若ParentImpl override了welcome方法，则会走ParentImpl方法

### 多继承

``` {.java}
interface Person {
    public default void welcome() {
        System.out.println("this is person");
    }
}

interface Parent {

    public default void welcome() {
        System.out.println("this is parent");
    }
}

class MultiChild implements Person, Parent {

    @Override
    public void welcome() {
        System.out.println("this is MultiChild");
    }
}
```

``` {.java}
class ChildImpl {
    public void welcome() {
        System.out.println("this is ChildImpl");
    }
}

interface Parent {

    public default void welcome() {
        System.out.println("this is parent");
    }
}

class OverrideChildImpl extends ChildImpl implements Parent {

}


      new OverrideChildImpl().welcome();//输出 this is ChildImpl


```

-   MultiChild实现了Parent，Person都有welcome方法，则子类MultiChild必须指定自己的welcome
-   子类只能一个了父类，但是可以有多个接口实现
-   OverrideChildImpl继承的父类和实现的接口当中都有welcome方法，则优先会走父类的方法；类优于接口
-   若OverrideChildImpl当中override了welcome方法，那么就会走子类的方法

