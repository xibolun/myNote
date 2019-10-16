---
date :  "2017-04-22T23:36:24+08:00" 
title : "Linux-awk" 
categories : ["技术文章"] 
tags : ["linux"] 
toc : true
---

### 关于awk

[awk](https://www.gnu.org/software/gawk/manual/gawk.html)是一门语言，而非单纯的一个小工具，其经典书  [The AWK Programming Language](https://book.douban.com/subject/1876898/)  于1988年出处，至此无再版；而国内的翻译版本为 [awk_zh-cn](https://github.com/wuzhouhui/awk/tree/twoside)；

### 语法

``` shell
 usage: awk [-F fs] [-v var=value] [-f progfile | 'prog'] [file ...] 
```

```
awk '条件 动作' 文件名
awk '动作' 文件名
```

-   -F: 指定分隔域的标识
-   -v: 指定命令/参数值
-   -f: 指定需要解析的文件

### Demo

输入/etc/passwd当中以:分隔的第一个域

```shell
awk -F ':' '{print $1}' /etc/passwd      
```

输入/etc/passwd当中以:分隔的第1，2两个域，注意$1与$2之间的字符串要添加""

```shell
awk -F ':' '{print $1 "\t" $2}' /etc/passwd
```

shell统计文件当中的行数

```shell
awk '{count++} END {print count}' /etc/passwd
```

print不带参数的时候，默认打印整行 

```shell
 echo -e "A line 1n A line 2" | awk {print}   
```

指定分隔符 'n',并打印第一个field 

```shell
 echo -e "A line 1n A line 2" | awk -F 'n' '{print $1}'
```

-F为空时，默认以空格分隔 

```shell
echo -e "A line 1n A line 2" | awk  '{print $1}'   
```

在{}当中定义变量，变量声明之间用 ; 进行分隔

```shell
echo | awk '{ var1="hello"; var2="world"; print var1,var2}'
```

### 内置变量

awk有一些内置的变量;

- `NF`： number of field
- `NR`:   当前行号
- `FILENAME` : 当前文件
- `FS`： 字段分隔符
- `RS`：行分隔符，默认是回车

### 实战

假如有一个`awk.txt`文件如下：

```txt
上海外滩-8楼-A01
上海外滩-8楼-A02
上海外滩-33楼-B01
上海外滩-33楼-B02
上海外滩-33楼-AP01
上海外滩-33楼-AP02
上海外滩-33楼-AP03
上海外滩-33楼-AP04
上海外滩-8楼-AP01
上海外滩-8楼-AP02
上海外滩-8楼-AP03
上海外滩-8楼-AP04
上海外滩-8楼-AP05
上海外滩-8楼-AP06
上海外滩-8楼-AP07
上海外滩-8楼-AP08
上海外滩-8楼-AP09
```

列出所有楼层

```shell
awk -F '-' '{print $2}' awk.txt
awk  -F '-' '{print $(NF-1)}' awk.txt  ## NF代表最后一个
```

对楼层进行去重

```shell
awk -F '-' '{print $2}' awk.txt | sort |uniq
```

对每一个房间号添加已经入住信息

```shell
awk '{print "已经入住: ", $0}' awk.txt
```

统计8楼的房间数

```shell
awk -F "-" '{if ($2 == "8楼") print $0}' awk.txt | wc -l
```

为每一行添加行号

```
awk -F '-' '{print NR ")" $0}' awk.txt 
```

只输出奇数行的房间号; 

```shell
awk -F "-" '{if (NR%2==1) print NR ")" $0}' awk.txt
```

格式化输出：房间号转为小写；awk[有一些内置的函数](https://www.gnu.org/software/gawk/manual/html_node/Built_002din.html#Built_002din)，有Time、string、Math相关

```shell
awk -F '-' '{print $1 "-" $2 "-" tolower($3) }' awk.txt
```

开头结尾添加分隔线

```shell
awk 'BEGIN {print "------------"} {print $0} END {print "------------"}'  awk.txt 
```

输出文件名字，注意此处需要添加`END`

```shell
awk 'END {print FILENAME}' awk.txt 
```

输出字符超过23的房间

```shell
awk '{if (length($0)>23)print $0}' awk.txt
```

输出1~9

```shell
echo "" | awk '{for (i=0;i<10;i++) print i}' 
```

### 运维命令

``` shell
lsof |awk '{print $2}'|uniq -c
```

### 参考 

- [awk_tutorialspoint](https://www.tutorialspoint.com/awk/index.htm) 这个教程很不错
- [gnu_gawk](https://www.gnu.org/software/gawk/)

