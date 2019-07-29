---
date :  "2017-10-10T23:36:24+08:00"
title : "Java8函数式编程笔记1~2"
categories : ["技术文章"] 
tags : ["java"] 
toc : true
---


前言
----

### 为什么要阅读本书

-   如何编写简单、干净、易读的代码，尤其是对于集合的操作
-   如何简单地使用并行计算提高性能
-   如何准确地为问题建模
-   如果写出更简单的并发代码
-   如何测试和调试Lambda表达式

第1章 简介
----------

### ?什么是函数式编程

-   核心是：在思考问题时，使用不可变值和函数，函数对一个值进行处理，映射成另一个值

第2章 Lambda表达式
------------------

### 第一个Lambda表达式

``` {.java}
        new Button().addActionListener(e -> {
            System.out.println("hello world");
        });
```

### 重要函数接口

``` {.java}
 public static void functionInterface() {
        /**
         * Predicate<T> 入参T,返回boolean
         */
        Predicate<Integer> persi = x -> x > 6;
        System.out.println(persi.test(10));

        /**
         * BinaryOperator<T> 入参T,T，返回T
         */
        BinaryOperator<Integer> binaryOperator = (x, y) -> x + y;
        System.out.println(binaryOperator.apply(10, 2));

        /**
         * Consumer<T> 入参T，无返回void
         */
        Consumer<Integer> consumer = (x) -> System.out.println(x);
        consumer.accept(10);

        /**
         * Function<T,R> 入参T，返回R 
         */
        Function<Integer, String> function = x -> x + "10";
        System.out.println(function.apply(10));

        /**
         * UnaryOperator<T> 入参T 返回T
         */
        UnaryOperator<Integer> unaryOperator = (x) -> x + 10;
        System.out.println(unaryOperator.apply(10));

        /**
         * Supplier<T> 入参None，返回T
         */
        Supplier<Integer> supplier = () -> 10;
        System.out.println(supplier.get());
    }
```

### 其他lambad表达式

``` {.java}
    public static void mapreducer() {
        System.out.println(Arrays.asList(1, 2, 3, 4, 5).stream().map(cost -> 5 + cost)
            .reduce(10, (sum, cost) -> sum + cost).toString());

        System.out
            .println(Arrays.asList(1).stream().reduce(10, (sum, cost) -> sum + cost).toString());

    }

    public static void mapcollect() {
        System.out.println(Arrays.asList("this", "is", "a", "chinese", "person").stream()
            .map(cost -> cost.toUpperCase()).collect(Collectors.joining(", ")));
        System.out.println(Arrays.asList("1", "2", "3", "4", "5", "0").stream()
            .map(cost -> 5 + cost).collect(Collectors.counting()));

    }
```

### 注意事项

-   lambda是一个表达式而已，可以称为闭包或者匿名函数
-   当一个类使用了@Functional注释的函数式接口，自带抽象函数方法或者单个抽象方法时才可以使用lambda
-   当不改变lambda当中的变量值的时候才可以使用方法引用；list.forEach(System.out::println);

``` {.java}
list.forEach(System.out::println);
```

-   在lambda当中的局部变量必须为final型的

