---

date :  "2019-07-25T11:53:51+08:00" 
title : "Tmux" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
---

有一些tmux的使用技巧，有时候会经常忘记，写一篇blog记录下来

### 什么是Tmux

[tmux](https://github.com/tmux/tmux)

### Tmux Features

- 多屏展示

- 多tab展示 ，一个tab里面可以开多个tab；以下是`iterm` 里面一个窗口下tmux进程的多个tab

  ```
  [0] 0:node# 1:zsh* 2:hugo# 3:go  4:tmp- 5:zsh 
  ```

- session保持；当不小心关闭当前窗口，tmux可以attach上一个会话；就此可以在跳板机上面开一个tmux，然后只要跳板机不关，tmux的进程一直会在，那样就不用每次ssh上去了

  ```
  ➜  ~ ps -ef | grep tmux
    501  6351     1   0 Thu09AM ??         0:26.70 tmux
    501  6349  6108   0 Thu09AM ttys003    0:00.02 tmux
    501 78663  7642   0  8:37PM ttys006    0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn tmux
  ```

### 配置文件

默认是在~/.tmux.conf下面，所有的配置项见 [example_tmu.conf](https://github.com/tmux/tmux/blob/master/example_tmux.conf)

### Hot key

Tmux所有的快捷键都是一个前缀来控制；前缀快捷键可以修改配置文件里面的`set-option -g prefix C-x` 我设置的是`Ctrl+x`，默认的是`Ctrl+a`

#### session操作

- `$` 重命名会话
- `d` 断开当前连接，或者`Ctrl+d`

```
tmux #新建一个默认的会话
tmux new -s foo # 新建名称为 foo 的会话
tmux ls # 列出所有 tmux 会话
tmux a # 恢复至上一次的会话
tmux a -t foo # 恢复名称为 foo 的会话，会话默认名称为数字
tmux kill-session -t foo # 删除名称为 foo 的会话
tmux kill-server # 删除所有的会话
```

#### panel操作

- `c` 新建Panel，此时当前Panel会切换至新Panel，不影响原有Panel的状态
- `,` 重命名panel
- `p` 切换至上一Panel
- `n` 切换至下一Panel
- `w` Panel列表选择，注意 macOS 下使用 `⌃p` 和 `⌃n` 进行上下选择
- `&` 关闭当前Panel
- `,` 重命名Panel，可以使用中文，重命名后能在 tmux 状态栏更快速的识别Panel id
- `0` 切换至 0 号Panel，使用其他数字 id 切换至对应Panel
- `f` 根据Panel名搜索选择Panel，可模糊匹配

#### 窗格操作

- `w` 显示panel列表
- `%` 左右平分出两个窗格
- `"` 上下平分出两个窗格
- `o` 选择下一个窗格，也可以使用上下左右方向键来选择
- `space` 切换窗格布局，tmux 内置了五种窗格布局，也可以通过 `⌥1` 至 `⌥5`来切换
- `x` 关闭当前窗格
- `{` 当前窗格前移
- `}` 当前窗格后移
- `;` 选择上次使用的窗格
- `z` 最大化当前窗格，再次执行可恢复原来大小

#### 

