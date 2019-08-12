---

date :  "2016-04-27T23:36:24+08:00" 
title : "Git学习" 
categories : ["技术文章"] 
tags : ["git"] 
toc : true
---

### GIT命令

#### git clone:

-   git clone -b develop --single-branch &lt;git-address&gt;
    :从git地址当中clone 指定的develop分支/或者在git
    repository当中指定此项目的默认branch

#### git add：

-   git add
    :将文件暂存，若多次修改，会暂存多个版本，但提交的快照只会保存最后一次的版本
-   git add -A ：暂存所有的新增，修改，删除过的文件

#### git diff：

-   git diff： 比较工作目录当中未暂存文件与暂存区快照的文件
-   git diff --cached：比较已经暂存文件与上次提交的快照文件

#### git commit

-   git commit -m ：提交添加注释信息
-   git commit -v ：提交时将修改差异添加至commit信息当中
-   git commit -a ：可以将示暂存的文件暂存后提交
-   git commit --amend：撤消刚提交的操作

#### git remove

-   rm file：从未暂存文件列表当中删除某文件
-   git rm：添加移除文件操作的记录信息
-   git rm --cached：从跟踪清单当中删除某些文件

#### git reset

-   git reset HEAD file：撤销此file的add操作
-   git reset --hard HEAD\^：撤销最后一次的commit

#### git checkout

-   git checkout -- file：取消对file的修改操作

#### git cherry-pick

- `git cherry-pick commit-id`  只合并此commit_id所提交的代码；区别于merge

#### git remote

-   git remote：显示远程仓库名称
-   git remote -v ：显示远程仓库地址
-   git remote add \[name\] \[url\]：添加一个远程仓库
-   git remote show \[remote-name\]：显示远程仓库的信息
-   git remote renmae \[remote-oldname\]
    \[remote-newname\]：重命名remote名称
-   git remote vm \[remote-name\]：删除remote
-   `git remote prune origin` 清空无用的分支

#### git tag

-   git tag ：列出现有的标签
-   git tag -l 'v1.4.2.\*'：列出1.4.2.\* 的所有版本标签
-   git tag -a ：添加新的标签
-   git tag -m ：为标签添加描述信息
-   git show \[version\]：显示此version下的标签信息
-   git tag -s \[version\] ：签署标签
-   git tag \[version\]：添加一个轻量标签
-   git tag -v \[version\]：验证已经签署过的version
-   git tag -a \[version\] \[log\]：为某个log添加标签
-   git push --tags ：提交git标签

#### git fetch

-   git fetch \[remote-name\] ：从远程仓库抓取数据

#### git push

-   git push \[remote-name\] \[branch-name\]：将数据推送至远程仓库当中
-   git push \[remote-name\] \[version\]：推送某一标签到remote上
-   git push \[remote-name\] --tags：推送所有标签到remote上

#### 远程操作

-   git remote add \[remote-name\] \[url\] ：添加一个远程分支
-   git fetch \[remote-name\] ：拉取远程分支
-   git push \[remote-name1\] \[remote-name2\]：推送remote2到remote1上
-   git checkout -b \[remote-branch-name\] \[remote-name\]
    ：从远程分支上面新建一个新的远程分支
-   git merge \[remote1\]/\[remote2\]：将remote2 merge到remote1

#### git rebase

-   git rebase master：将当前分支衍合至master上

#### git merge

-   压缩合并git merge --squash develop
    ：将develop分支上所有的提交merge到当前分支成一条提交，需要在当前分支上再进行commit操作
-   拣选合并git cherry-pick
    &lt;commit-num&gt;：将其他分支的commit-num所提交的代码merge到当前分支,当前分支不需要再进行commit操作
-   git cherry-pick -n
    &lt;commit-nums&gt;：merge多个commit号到当前分支，需要在当前分支上再进行commit操作

#### git log

-   git log --graph --abbrev-commit --decorate
    --format=format:'%C(bold blue)%h%C(reset) -
    %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)-
    %an%C(reset)%C(bold yellow)%d%C(reset)' --all
-   git log --graph --abbrev-commit --decorate
    --format=format:'%C(bold blue)%h%C(reset) -
    %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)-
    %an%C(reset)%C(bold yellow)%d%C(reset)' develop : 只看develop分支
-   git log --graph --abbrev-commit --decorate
    --format=format:'%C(bold blue)%h%C(reset) -
    %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold
    yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)-
    %an%C(reset)' --all

#### git branch

-   git branch ：查看当前仓库的所有分支列表
-   git branch
    \[branch-name\]：创建一个分支（如果是一个新的git仓库，则需要修并提交后才可以创建）
-   git checkout \[branch-name\]：切换分支
-   git branch -d
    \[branch-name\]：删除分支（若分支未被merge，则会提示错误信息）
-   git branch -D \[branch-name\]: 强制删除分支
-   git branch -m \[branch-name\] \[newBranch-name\]:重命名分支
-   git branch -M \[branch-name\] \[newBranch-name\]:强制重命名分支
-   git branch -b \[branch-name\]：创建并切换分支
-   git merge \[branch-name\]：当对应的分支合并至当前分支
-   git branch --merged：查看已经被merge的分支
-   git branch --no-merged：查看未被merge的分支
-   git branch -a : 查看本地和远程的所有分支
-   git branch --track origin/develop :
    从远程的branch下载分支，并在本地创建develop
-   git push --delete origin develop: 删除远程的develop分支

#### git clean

-   git clean -f : remove untracked files
-   git clean -fd : remove untracked directories

#### git stash

- git stash: 存储变更
- git stash save 'message': 为stash添加存储的信息，查看并回滚
- git stash list ：查看现有的存储列表
- git stash drop {stash@1}：删除指定的stash信息
- git stash show {stash@1}：查看指定stash文件信息

### 如何重命名远程分支

-   git branch --track origin devel
    ：从远程下载devel分支至本地（如果本地没有远程分支的代码）
-   git branch -m devel develop :将devel重命名为develop
-   git push origin develop: 提交develop分支至远程
-   git push --delete origin devel: 删除远程分支devel

### git概念

#### 跟踪与未跟踪

-   在git当中新增一个文件，文件状态为untracked，称为未跟踪
-   然后执行add命令后，git提示信息为changes to be
    committed，此时文件被跟踪了
-   在git当中修改一个文件，文件状态为modified，git提示信息为changes not
    staged for commit文件之前就是被跟踪的，现在也是被跟踪

### git其他命令

-   查看git tag 日期，信息：`git for-each-ref --format="%(refname:short)
    %(taggerdate) %(subject) %(body)" refs/tags`
-   添加.gitignore之后，git还会标记ignore的文件，用git rm -rf --cached
    FILENAME将缓存删除

### git文章

-   [The simple guide no deep
    shit](http://rogerdudler.github.io/git-guide/)

### ssh认证原理

``` {.txt}
ssh 的密钥认证就是使用了这一特性。服务器和客户端都各自拥有自己的公钥和密钥。 为了说明方便，以下将使用这些符号。
Ac 客户端公钥
Bc 客户端密钥
As 服务器公钥
Bs 服务器密钥
在认证之前，客户端需要通过某种方法将公钥 Ac 登录到服务器上。
认证过程分为两个步骤。
一、 会话密 钥(session key)生成
1. 客户端 请求连接服务器，服务器将 As 发送给客户端。
2. 服务器生成会话ID(session id)，设为 p，发送给客户端。
3. 客户端生成会话密钥(session key)，设为 q，并计算 r = p xor q。
4. 客户端将 r 用 As 进行加密，结果发送给服务器。
5. 服务器用 Bs 进行解密，获得 r。
6. 服务器进行 r xor p 的运算，获得 q。
7. 至此服务器和客户端都知道了会话密钥q，以后的传输都将被 q 加密。
二、 认证
1. 服务器 生成随机数 x，并用 Ac 加密后生成结果 S(x)，发送给客户端
2. 客户端使用 Bc 解密 S(x) 得到 x
3. 客户端计算 q + x 的 md5 值 n(q+x)，q为上一步得到的会话密钥
4. 服务器计算 q + x 的 md5 值 m(q+x)
5. 客户端将 n(q+x) 发送给服务器
6. 服务器比较 m(q+x) 和 n(q+x)，两者相同则认证成功
```
