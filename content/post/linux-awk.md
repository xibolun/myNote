+++
date = "2017-04-22T23:36:24+08:00"
title = "Awk学习"

+++

常用Command
-----------

### find

### awk

#### 语法

``` {.shell}
 usage: awk [-F fs] [-v var=value] [-f progfile | 'prog'] [file ...] 
```

-   -F: 指定分隔域的标识
-   -v: 指定命令/参数值
-   -f: 指定需要解析的文件

#### Demo

``` {.shell}
 awk -F ':' '{print $1}' /etc/passwd                                                  ##输入/etc/passwd当中以:分隔的第一个域
 awk -F ':' '{print $1 "\t" $2}' /etc/passwd                                                                                 ##输入/etc/passwd当中以:分隔的第1，2两个域，注意$1与$2之间的字符串要添加""
 awk '{count++} END {print count}' /etc/passwd                                                                             ##统计文件当中的行数
 echo -e "A line 1n A line 2" | awk {print}                                                                              ##print不带参数的时候，默认打印整行 
 echo -e "A line 1n A line 2" | awk -F 'n' '{print $1}'                                                          ##指定分隔符 'n',并打印第一个field 
 echo -e "A line 1n A line 2" | awk  '{print $1}'                                                                        ## -F为空时，默认以空格分隔 
 echo | awk '{ var1="hello"; var2="world"; print var1,var2}'                                               ##在{}当中定义变量，变量声明之间用 ; 进行分隔
```
