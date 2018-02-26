+++
date = "2017-10-10T23:36:24+08:00"
title = "Java8函数式编程笔记第3章"

+++


第3章 流
--------

### 外部迭代与内部迭代

``` {.java}
 public static void innerLoop() {

        /**
         * 运算结果为：50005000共计耗时：3
         * 运算结果为：50005000共计耗时：119
         */

        int sum = 0;
        Set<Integer> set = new HashSet<>();
        for (int i = 0; i <= 10000; i++) {
            set.add(i);
        }

        long start = System.currentTimeMillis();

        for (int i : set) {
            sum += i;
        }

        long end = System.currentTimeMillis() - start;

        System.out.println("运算结果为：" + sum + "共计耗时：" + end);

        long _start = System.currentTimeMillis();

        sum = set.stream().reduce((count, x) -> count + x).get();

        long _end = System.currentTimeMillis() - _start;

        System.out.println("运算结果为：" + sum + "共计耗时：" + _end);

    }
```

#### 惰性求值与过早求值

-   返回值为Stream为惰性求值；返回值为空或为另外一个值为及早求值
-   使用惰性求值的好处就是可以形成惰性求值链，可以一直stream下去

#### 什么是高阶函数？函数的入参为函数

### 常用写法 ###

``` java
            Node node = graphDatabaseService.createNode();
            node.addLabel(Label.label(label));
            
            properties.entrySet().forEach(entry->{
                node.setProperty(entry.getKey(),entry.getValue());
            });
            
            properties.forEach((key, value) -> node.setProperty(key, value));

            properties.forEach(node::setProperty);
```

### 常用流操作

``` {.java}
  public static void streamMethod() {
        /**
         * collect(toList)
         */
        List<String> collected = Stream.of("a", "b", "c", "d").collect(Collectors.toList());

        /**
         * map  Function<T,R>
         */
        Stream.of("a", "b", "c", "d").map(str -> str.toUpperCase()).collect(Collectors.toList());

        /**
         * filter  Predicate<T>
         */
        Stream.of("a", "b", "c", "d").filter(str -> str.equals("a")).collect(Collectors.toList());

        /**
         * flatMap
         */
        Stream.of(Arrays.asList("a", "b"), Arrays.asList("c", "d")).flatMap(str -> str.stream())
            .collect(Collectors.toList());

        /**
         * max and min
         */
        System.out.println(Stream.of(1, 2, 4).max(Comparator.comparing(x -> x)).get());
        System.out.println(Stream.of(1, 2, 4).min(Comparator.comparing(x -> x)).get());

    }

    public static void reduceTest() {
        /**
         * acc即为sum
         */
        System.out.println(Stream.of(1, 2, 3).reduce(0, (acc, el) -> acc + el));
    }
```
