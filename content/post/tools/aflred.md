---
date :  "2023-04-27 10:24:20+08:00"
title : "Alfred snippets日期格式化" 
categories : ["tools"] 
tags : ["alfred"] 
toc : true
description: alfred snippets data forma
---



## Alfred snippets PlaceHolder

snippets是一个快捷定制化短语的功能，我一般会将常用的一些命令、文本信息放在其内；它有一些动态的输入方式，像python的jinjia模板一样；

举例

- 生成uuid：` {random:UUID}`
- 添加一段时间：` {datetime}`

### 日期格式化

如何格式化时间呢？Alfred的格式化遵循 [UNICODE LOCALE DATA MARKUP LANGUAGE (LDML)](https://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Field_Symbol_Table)标准

例如：标准的年-月-日： `{date: yyyy-MM-dd}` 关键字为 `date`，接一下冒号就是 `format`，后面的 `yyyy-MM-dd`是需要 `format`的格式；

从文档当中可以看出：

- 日期的format是大小写敏感：例： w是一年的每几周； W是每月的第几周
- 日期的format与字母的次数有关， 例：如果是9月份， M代表9，MM为09，MMM为Sept，MMMM为September，MMMMMM为S

所以可以开始format你的日期，

- 年-本年第几个月-本年每几周： `{date: YYYY-MM-W}`