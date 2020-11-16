---

date :  "2020-11-05T10:01:27+08:00" 
title : "CodeQL" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
---

## 给你的代码加上CodeQL

`github`推出了`code scanning`的功能，今天在给`github`提PR的时候才学习着使用；

在`.git/workflows`里面添加`codeql-analysis`文件，这个文件也可以在 `github`上面创建`workflow`时创建出来；

```shell
name: "CodeQL"

on:
  push:
    branches: [master, develop]
  pull_request:
    # The branches below must be a subset of the branches above
    branches: [master]
  schedule:
    - cron: '0 4 * * 5'

jobs:
  analyse:
    name: Analyse
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2
      with:
        # We must fetch at least the immediate parents so that if this is
        # a pull request then we can checkout the head.
        fetch-depth: 2

    # If this run was triggered by a pull request event, then checkout
    # the head of the pull request instead of the merge commit.
    - run: git checkout HEAD^2
      if: ${{ github.event_name == 'pull_request' }}

    # Initializes the CodeQL tools for scanning.
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v1
      # Override language selection by uncommenting this and choosing your languages
      # with:
      #   languages: go, javascript, csharp, python, cpp, java

    # Autobuild attempts to build any compiled languages  (C/C++, C#, or Java).
    # If this step fails, then you should remove it and run the build manually (see below)
    - name: Autobuild
      uses: github/codeql-action/autobuild@v1

    # ℹ️ Command-line programs to run using the OS shell.
    # 📚 https://git.io/JvXDl

    # ✏️ If the Autobuild fails above, remove it and uncomment the following three lines
    #    and modify them (or add more) to build your code if your project
    #    uses a compiled language

    #- run: |
    #   make bootstrap
    #   make release

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v1

```

从上面的文件里面可以看出

- 当你提交代码至`master\develop`分支，或`PR`到`master`分支时会自动触发此`workflow`；
- 下面有多种`jobs`

由于每次提交才能触发此机制，那能否像`.git/hooks`里面的机制，可以在提交的时候就触发，免得代码冗余，给开发者带来一些不好的感受呢？那就需要使用一些代码分析工具 [CodeQL  tools](https://help.semmle.com/QL/ql-tools.html) ，准备使用`LGTM`来看看效果

### LGTM

一个代码分析工具，它有一个命令行工具，可以下载安装进行操作一下看看效果；

- [对golang工程的分析准备](https://help.semmle.com/wiki/pages/viewpage.action?pageId=40698058)

#### 安装

下载软件包，是一个zip包，大概1000M；下载完成后，解压并安装

```
1. `mv ~/Downloads/odasa*.zip ${install_loc}`
2. `cd ${install_loc}`
3. `xattr -c odasa*.zip` // 去除@符号
4. `unzip odasa*.zip`
```

大小大约1.5G

```
➜  odasa du -sh
1.5G    .
```

为什么这么大？ 看了一下，把缓存、`node modules`、`jar`等各个东西都打包完成

执行`setup.sh`进行安装，需要一个`license`文件；

