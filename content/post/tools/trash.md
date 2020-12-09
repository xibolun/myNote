---

date :  "2017-05-09T10:42:16+08:00" 
title : "mac避免rm -rf悲剧" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
---

### 安装Trash

[Trash](https://formulae.brew.sh/formula/trash)是一个命令行工具，将文件或者目录移除至Trash当中

```shell
brew install trash
```

### 添加alias

添加alias至`~/.zshrc`当中

```
alias rm=trash
alias r=trash
alias rl='ls ~/.Trash'
alias ur=undelfile
undelfile()
{
    mv -i ~/.Trash/$@ ./
}
```

```shell
source ~/.zshrc
```

### 测试

```shell
➜  /tmp ll | grep oob
-rw-rw-rw-@ 1 admin  wheel   466B Dec  9 09:36 oobelib.log
## 删除一个文件
➜  /tmp rm -rf oobelib.log
## 将文件恢复
➜  /tmp mv ~/.Trash/oobelib.log .
```

### 其他操作

```shell
## 查看回收站文件列表
➜  ~ trash -l
/Users/admin/.Trash/act2_playbook.retry
## 有确认地清空回收站
➜  ~ trash -e
There is currently 1 item in the trash.
Are you sure you want to permanently delete this item?
(y = permanently empty the trash, l = list items in trash, n = don't empty)
## 无确认地清空回收站
➜  ~ trash -y
```

