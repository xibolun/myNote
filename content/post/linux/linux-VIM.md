---
date :  "2017-04-07T15:02:17+08:00" 
title : "Linux-Vim" 
categories : ["技术文章"] 
tags : ["linux"] 
toc : true
---

### 删除

- `:3,5d` : 删除3~5行
- `:.,+2d`: 删除当前行及后面两行
- `:1,.-1d` ：删除当前行之前
- `:.+1,$d`: 删除当前行之后
- `:g /word/d`: 删除包括`word`的所有行
- `:%g! /word/d`: 删除不包括word的所有行; `:v /word/d`

