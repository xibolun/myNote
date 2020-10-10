---

date :  "2020-10-10T16:58:14+08:00" 
title : "Git对象" 
categories : ["技术文章"] 
tags : ["git"] 
toc : true
---

### 一个常规操作

先看一个常规的操作；

```shell
mkdir /tmp/common
cd /tmp/common
git init
echo "text content" > test.txt
git add .
```

上述几个命令就是创建一个目录，并将其初始化为git工程，添加一个文件，然后使用`git add`添加至缓冲区，先不要提交；由于`git`的存储对象都是放在`objects`目录下面，这个时间看看`objects`目录的信息

```shell
➜  common git:(master) ✗ find .git/objects -type f
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
```

有了一个`d6`开头的文件夹，里面有一个`70460b4b4aece5915caf5c68d12f560a9fe3e4`文件；

文件的内容即为`test.txt`里面的内容

```
➜  common git:(master) git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4
test content
```

看看文件的类型为`blob`

> 说明：git用四种存储数据类型：blob/tree/commit/tag； 其中blob即为文件，tree为目录，tree可以嵌套

```
➜  common git:(master) git cat-file -t d670460b4b4aece5915caf5c68d12f560a9fe3e4
blob
```

然后我们再执行`commit`操作，看看发生了什么

```shell
➜  common git:(master) ✗ gcam "add file test.txt"
[master (root-commit) 1411e43] add file test.txt
 1 file changed, 1 insertion(+)
 create mode 100644 text.txt
```

```shell
➜  common git:(master) find .git/objects -type f
.git/objects/d6/70460b4b4aece5915caf5c68d12f560a9fe3e4
.git/objects/e5/ad8d7c68ffd2b55209ab9a1078600fb7deeb3d
.git/objects/14/11e43caf627123774c1d6fcbf8478f5f57d38f
```

发现`objects`目录里面多了几个文件；继续看看他们的信息

```shell
➜  common git:(master) git cat-file -t e5ad8d7c68ffd2b55209ab9a1078600fb7deeb3d
tree
➜  common git:(master) git cat-file -p e5ad8d7c68ffd2b55209ab9a1078600fb7deeb3d
100644 blob d670460b4b4aece5915caf5c68d12f560a9fe3e4    text.txt
➜  common git:(master) git cat-file -t 1411e43caf627123774c1d6fcbf8478f5f57d38f
commit
➜  common git:(master) git cat-file -p 1411e43caf627123774c1d6fcbf8478f5f57d38f
tree e5ad8d7c68ffd2b55209ab9a1078600fb7deeb3d
author pengganyu <peng_gy@163.com> 1602320472 +0800
committer pengganyu <peng_gy@163.com> 1602320472 +0800

add file test.txt
```

`e5ad8d7c68ffd2b55209ab9a1078600fb7deeb3d`是一个`tree`格式的对象，里面存储着`text.txt`，简单理解为它是一个目录，里面为`text.txt`

`1411e43caf627123774c1d6fcbf8478f5f57d38f`是一个`commit`格式的对象，里面存储着提交的信息；关联的目录为`e5ad8d7c68ffd2b55209ab9a1078600fb7deeb3d`;

而`commit`的信息也会存放在`COMMIT_EDITMSG`里面

```shell
➜  common git:(master) cat .git/COMMIT_EDITMSG
add file test.txt
```

### 存储区说明

- 工作目录、缓存区、对象数据库
- text.txt的生命周期
  - 工作目录：创建、写入内容
  - 缓存区： `git add`操作
  - 对象数据库：每一个动作都会生成一个对象存储
    - `blob`记录文件内容
    - `tree`记录文件名称、目录关系
    - `commit`记录文件提交信息

### 脱离命令实现

`git`有上层命令，类似`git add/status/commit/pull/push......`，约有30个；还有底层命令，类似`git cat-file/hash-objects/wirte-tree......`

下面我们来使用底层命令来实现上面的操作；

```shell
mkdir /tmp/common
cd /tmp/common
git init
echo "text content" > test.txt
```

前置操作一样；

```shell
## 对test.txt进行hash处理，处理完成，在对象区里面存储了一个blob对象
➜  common git:(master) ✗ git hash-object -w test.txt
d670460b4b4aece5915caf5c68d12f560a9fe3e4
## 更新索引，添加文件至仓库
➜  common git:(master) ✗ git update-index --add test.txt
## 以当前文件目录为tree，将索引写入
➜  common git:(master) ✗ git write-tree
80865964295ae2f11d27383e5f9c0b58a8ef21da
## 创建提交的commit存储对象
➜  common git:(master) ✗ echo "add test.txt" | git commit-tree\ 80865964295ae2f11d27383e5f9c0b58a8ef21da
139617a6c21c532bcc957b84b99e95a9b693ae7d
## 查看log日志
➜  common git:(master) ✗ git log --stat 139617a6c21c532bcc957b84b99e95a9b693ae7d
```

### 参考

- [git官方文档](https://git-scm.com/book/zh/v2/Git-%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86-Git-%E5%AF%B9%E8%B1%A1)

- [Git内部原理](https://juejin.im/post/6844904019245137927)： 以图文并茂的方式进行编排

