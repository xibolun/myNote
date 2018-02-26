+++
date = "2017-07-20T23:36:24+08:00"
title = "Python学习"

+++

基础
====

语法
----

-   and : &&
-   or : ||
-   elif : if else
-   if、for后面是:
-   if **~name~\_** == '**~main~\_**': main方法，方法的入口
-   str(10) : 将int转换为str
-   int('1'): 将str转换为int

2 Using the Python Interpreter
------------------------------

-   python打开python的解释器，若命令不存在，请检查Path环境变量
-   Ctrl+D或quit() 关闭Interpreter; windows是Ctrl+z
-   Interpreter里面自带命令历史，可以通过ctroller+P去查找上一个命令
-   python3 xx.py: 执行python

3 Using Python as a Calculator
------------------------------

``` {.python}
>>> 2** 3   ## 2的3次方
8
>>> 10 / 3   ## 10除以3
3.3333333333333335
```

生态
====

工具
----

### pip3 包管理工具

-   easy~install~ pip 安装包管理工具；或从官网下载
-   pip install --upgrade pip : 升级包管理工具
-   pip install markdown 使用pip安装软件包
-   pip freeze: pip安装的软件包列表

### ipython

-   import inspect && print(inspect.get(range)) :
    即可看到range函数的说明信息
-   brew install ipython : 安装ipython的函数说明，使用方法range?
    中间没有空格
-   range? 快速查找函数说明
-   支持命令行相关工具

其他类库
--------

### xlrd : python读取excel

``` {.python3}
import xlrd

if __name__ == '__main__':
    data = xlrd.open_workbook("/tmp/test.xlsx")
    sheet = data.sheets()[0]
    nrows = sheet.nrows
    ncols = sheet.ncols
    for rowNum in range(0, nrows):
        row = sheet.row_values(rowNum)
        for colNum in range(0, ncols):
            cell = row[colNum]
            print(cell)
```



## 虚拟环境

- pip3 install virtualenv: 安装虚拟环境
- ​
- virtualenv pyenv3 : 创建一个虚拟环境目录


- source pyenv3/activate: 启动虚拟环境工作


- deactivate: 退出虚拟环境工作

