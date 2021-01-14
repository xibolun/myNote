---

date :  "2021-01-12T22:39:52+08:00" 
title : "M1的艰辛使用之旅" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
description: mac m1 rosetta
---

## M1的艰辛使用之旅

公司给每个同学置换了mac，由于docker已经支持了M1版本，所以我也入手了一台，想体验一把传说中的神器，不想自己掉坑里了；花了两天的时间才把东西弄全；

### 迁移

迁移比较简单，打开迁移助手即可。虽然很简单，但是仍然遇到了问题，因为老电脑上面的数据太多了，256G几乎满了的状态，导致迁移的时候，新电脑上面的文件没有迁移完，直接就报错了；最后打开一看，里面许多的命令都没有，那只有重新迁移了；但是已经迁移了一部分，所以需要抹掉，重新安装再进行迁移；

想想迁移过程当中的漫长等待，我有苦说不出来；

### 重装

重装的过程也比较艰辛；因为mac开启了[【自动启动】功能](https://discussionschinese.apple.com/thread/250833364)，所以我按【cmd+R】想进入恢复模式，无法进入；于是我就按着上面的说法修改了一个参数，直接就启动不起来了；

启动后报错样子大概如下：

```
support.apple.com/mac/restore 
```

 [Mac启动异常](https://support.apple.com/zh-cn/HT211868?cid=mc-ols-mac-article_ht211868-macos_ui-09292020)，链接当中也给出了解决方案，就是拿另外一台电脑，使用`apple configuration`把它弄起来，我尝试了，没有瓜；最后还是使用了【shift+cmd+option+R】快捷键最终进入了恢复安装的界面；

### 安装过程

在两个盘【Macintosh HD】还有一个【Data】，这两个盘我都给抹掉了，因为我已经迁移过一次了，里面有一些文件，虽然我已经抹掉了，但是仍然存在，所以安装到应用程序的时候又报错了；

报错信息如下：

```shell
failed to personalize the software update. please try again
```

解决方式 [resetpassword](https://support.apple.com/en-us/HT211983)，然后再重新抹盘，再重新安装，最后终于装好了；

### 软件无法更新

安装好了之后，我发现有一些软件可以运行，qq\wps等，但像weixin\dingding都无法使用；原因乃是缺少`rosetta`，需要进行安装，但是我死活安装不了，提示如下：

```
请确定您已经连接互联网
```

但是我明明在连接互联网，什么情况？

我使用命令行工具更新的时候，发现请求的域名乃是`apple.xxxx`

```
sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
```

最后我看了一下我的配置文件，发现域名解析出错了，将`apple`相关的域名解析给去掉，得以成功安装`rosetta`

### 必需的软件

- Jetbrains家族： Goland\DataGrip\Pycharm
- Alfred：注意使用4.2.1 1183版本
- Postman：所有存储的API请求设置都会进行同步
- Docker M1版本：[download](https://docs.docker.com/docker-for-mac/apple-m1/)
- 工具类： [vscode Arm版本](https://code.visualstudio.com/docs/?dv=darwinarm64&build=insiders)、Mindnode、网易邮箱、Reeder、wps、iterm2、emacs
- 通讯类：钉钉、微信、QQ
- 笔记类：有道、语雀、Typora、
- 其他：[Flux](https://justgetflux.com/mac/Flux.zip)一个护眼的工具、百度网盘
- 命令行工具：git、trash、wrk、go、hugo、tmux、brew、ag、pandoc、swag、swagger、swagger-markdown

### 目前遇到的问题

- Goland闪退
- [Virtualbox不支持ARM](https://forums.virtualbox.org/viewtopic.php?f=8&t=98742)

### 参考

- [Error! If trying to Reinstall macOS Big Sur On Apple Silicon Macs](https://mrmacintosh.com/reinstalling-big-sur-on-apple-silicon-macs-with-11-0-20a2411-error/)
- [If you get a personalization error when reinstalling macOS on your Mac with Apple M1 chip](https://support.apple.com/en-us/HT211983)

