---

date :  "2018-09-04T10:30:23+08:00" 
title : "Spacemacs" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
---

## Spacemacs ##

### 配置evil中英文输入法切换 ###

> 此操作只针对于mac
mac安装 [fcitx-remote-for-osx](https://github.com/xcodebuild/fcitx-remote-for-osx) 

``` shell
git clone https://github.com/xcodebuild/fcitx-remote-for-osx.git
cd fcitx-remote-for-osx
./build.py build all
```
编译完成后，你会得到很多种输入法

``` shell
ll | grep fcit
drwxr-xr-x  3 pgy  staff    96B  7 29 14:29 fcitx-remote
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-baidu-pinyin
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-baidu-wubi
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-general
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-loginput
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-loginput2
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-osx-pinyin
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-osx-shuangpin
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-osx-wubi
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-qingg
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-qq-wubi
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-sogou-pinyin
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-squirrel-rime
-rwxr-xr-x  1 pgy  staff    51K  8  3 17:35 fcitx-remote-squirrel-rime-upstream
drwxr-xr-x  4 pgy  staff   128B  7 29 14:29 fcitx-remote.xcodeproj
```
将你喜欢的输入法copy至PATH下面即可

``` shell
sudo cp ./fcitx-remote-baidu-wubi /usr/local/bin/fcitx-remote
```

在spacemacs当中配置
- 首先 M-x -> package-install 输入 fcitx安装，一般会安装在 `/Users/pgy/.emacs.d/elpa/27.2/develop`目录当中
- 安装完成后，在`.spacemacs`当中的`user-config`添加如下配置
``` emacs-lisp
  ;; --------  Config fcitx ----------------
  ;; (add-to-list 'load-path "~/.emacs.d/private/fcitx.el")
  ;; (require 'fcitx)
  (load-file "~/.emacs.d/private/fcitx.el")
  (require 'fcitx)
  (fcitx-evil-turn-on)

```

### 基础操作 ###
- 折叠所有title
- `SPC h SPC` : 可以打开官网文档、layers列表等

### 模式列表 ###
- avy： 能够快速跳转至某一行，某一个单词里面；即所见即所得的模式
- ido: 可以进行目录和文件相关操作
- neotree: 文件树操作

### DotFile ###
-  SPC f e R   //刷新emacs配置
-  M-X dotspacemacs/test-dotfile  //测试dotfile是否存在error

### Edit ###

#### 注释 ####
- [Commenting](http://spacemacs.org/doc/DOCUMENTATION#commenting) 


### org ###
- SPC t l    // 设置截取行开关

#### evil ####
- selection M-x iedit-mode (https://github.com/syl20bnr/evil-iedit-state)


#### MyConf
[.spacemacs](https://github.com/xibolun/emacsConfig/blob/master/private/.spacemacs "spacemacs config")

