---
date :  "2023-04-26 11:21:07+08:00"
title : "xmlsec安装报错" 
categories : ["python"] 
tags : ["排障"] 
toc : true
description:  Could not build wheels for xmlsec Failed to build xmlsec 
---

## xmlsec安装报错

主机环境：macos M2

```
✗ uname -a
Darwin pgy.local 22.3.0 Darwin Kernel Version 22.3.0: Mon Jan 30 20:38:43 PST 2023; root:xnu-8792.81.3~2/RELEASE_ARM64_T8112 arm64
```

python版本： 

```
 ✗ pyenv --version && python -V
pyenv 2.3.17
Python 3.9.1
```

### 安装依赖

官方安装文档为：[xmlsec 1.3.13](https://pypi.org/project/xmlsec/)，安装步骤为

```
xcode-select --install
brew install libxml2 libxmlsec1 pkg-config
```

安装完成后查看libxml、libxmlsec1的版本号如下：

```
brew info libxml2 libxmlsec1
==> libxml2: stable 2.10.4 (bottled), HEAD [keg-only]
==> libxmlsec1: stable 1.3.0 (bottled)
```

官方要求版本为：

```
libxml2 >= 2.9.1
libxmlsec1 >= 1.2.1
```

### 安装报错

依赖环境已经安装完成，但是安装xmlsec会有如下报错：

```
 ✗ pip install xmlsec
 ......
      /private/var/folders/k1/yj7yrdw10dl0cxxmn367p3fh0000gn/T/pip-install-ex8ixgt1/xmlsec_3a2a32a5f68a419094c99329d69797d7/src/constants.c:320:5: error: use of undeclared identifier 'xmlSecSoap12Ns'; did you mean 'xmlSecXPath2Ns'?
          PYXMLSEC_ADD_NS_CONSTANT(Soap12Ns, "SOAP12");
          ^
      /private/var/folders/k1/yj7yrdw10dl0cxxmn367p3fh0000gn/T/pip-install-ex8ixgt1/xmlsec_3a2a32a5f68a419094c99329d69797d7/src/constants.c:304:46: note: expanded from macro 'PYXMLSEC_ADD_NS_CONSTANT'
          tmp = PyUnicode_FromString((const char*)(JOIN(xmlSec, name))); \
                                                   ^
      /private/var/folders/k1/yj7yrdw10dl0cxxmn367p3fh0000gn/T/pip-install-ex8ixgt1/xmlsec_3a2a32a5f68a419094c99329d69797d7/src/common.h:19:19: note: expanded from macro 'JOIN'
      #define JOIN(X,Y) DO_JOIN1(X,Y)
                        ^
      /private/var/folders/k1/yj7yrdw10dl0cxxmn367p3fh0000gn/T/pip-install-ex8ixgt1/xmlsec_3a2a32a5f68a419094c99329d69797d7/src/common.h:20:23: note: expanded from macro 'DO_JOIN1'
      #define DO_JOIN1(X,Y) DO_JOIN2(X,Y)
                            ^
      /private/var/folders/k1/yj7yrdw10dl0cxxmn367p3fh0000gn/T/pip-install-ex8ixgt1/xmlsec_3a2a32a5f68a419094c99329d69797d7/src/common.h:21:23: note: expanded from macro 'DO_JOIN2'
      #define DO_JOIN2(X,Y) X##Y
                            ^
      <scratch space>:139:1: note: expanded from here
      xmlSecSoap12Ns
      ^
      /opt/homebrew/Cellar/libxmlsec1/1.3.0/include/xmlsec1/xmlsec/strings.h:34:33: note: 'xmlSecXPath2Ns' declared here                                                                                                                                                            XMLSEC_EXPORT_VAR const xmlChar xmlSecXPath2Ns[];                                                                                                                                                                                                                                                             ^                                                                                                                                                                                                                                             197 warnings and 2 errors generated.                                                                                                                                                                                                                                          error: command '/usr/bin/clang' failed with exit code 1                                                                                                                                                                                                                       [end of output]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         note: This error originates from a subprocess, and is likely not a problem with pip.                                                                                                                                                                                          ERROR: Failed building wheel for xmlsec
Failed to build xmlsec                                                                                                                                                                                                                                                        ERROR: Could not build wheels for xmlsec, which is required to install pyproject.toml-based projects
```

### 报错分析与解决

从报错信息可以看出： brew已经成功安装了libxmlsec1，但xmlsec依旧报错，报错原因是brew安装的libxmlsec1的库有问题，导致存在一些语法的错误；

从官方的一个issues当中可以看到，libxml的包确实在M2上面有一些问题，按照issues当中的方式，替换libxmlsec1.rb文件即可

https://github.com/xmlsec/python-xmlsec/issues/254

对比一下两个文件的差异，只是将新版本1.3.0替换为了1.2.37

```
url "https://www.aleksey.com/xmlsec/download/xmlsec1-1.3.0.tar.gz"                                                                 url "https://www.aleksey.com/xmlsec/download/xmlsec1-1.2.37.tar.gz"
```

