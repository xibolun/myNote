---
date :  "2019-02-22T18:47:21+08:00" 
title : "使用Hugo&GitPage写博客" 
categories : ["tool"] 
tags : ["hugo","tool"] 
toc : true
---

本文主要是介绍一下我是怎么写博客，并且发布的。

### 最早方式

早期入了`emacs`的坑，喜欢上了 [Org-mode](http://orgmode.org/worg/org-tutorials/)(org-mode十分强大，尤其它的`Agenda`、`TODO`管理功能)所以写东西一般都是使用`emacs`的`org-mode`，然后使用 [org-page](https://github.com/sillykelvin/org-page)进行发布。

后来发现了Hugo，最早版本支持org，所以就拿来用了一下，但是后来好像支持力度不算非常的友好，自己的文档也不算太多，就转了`markdown`，但是有一些大牛写了一些转换的组件，若有兴趣可以去参考 [使用 orgmode & hugo 撰写博文的流程介绍](https://emacs-china.org/t/topic/5427)；并且org本身也支持转换markdown(https://ox-hugo.scripter.co/)

### Hugo

Hugo是一个go语言写的静态博客生成器，与业界里面的Jeklly、Hexo等类似，但Hugo更快，并且早期版本的Hugo支持 [Org-mode](http://orgmode.org/worg/org-tutorials/) 现在对`markdown`更加友好

[quick-start](https://gohugo.io/getting-started/quick-start/)可以快速入门进行使用，Hugo还自带命令行工具

### 主题

最早找了许多的主题，但是最终选择了广东一个哥们的 [blog](https://blog.coderzh.com/)，他是做游戏的，我用他的主题 [hugo-pacman-theme](https://themes.gohugo.io/hugo-pacman-theme/)的原因就是支持归档，支持标签，看着色彩也还可以。我用了大概两年的时间；

后来看到阿里的一位大牛的博客 [飞雪无情](https://github.com/rujews/maupassant-hugo)，感觉非常好看，所以就拿过来用了一下 [maupassant-hugo](https://github.com/rujews/maupassant-hugo)；于2019年2月份左右迁移完成。

### 发布

Hugo官网文档里面有许多的发布方式 [hosting-and-deploymeng](https://gohugo.io/hosting-and-deployment/)，

说一下大概的思路：如果你自己部署你需要以下操作

- 申请一台云服务器，阿里云/腾讯云/......
- 将`hugo build`出来的文件放在服务器上面，使用nginx做代理
- 如果你想用网址域名，那你需要去买一个域名，然后再进行备案

而github推出的有 [gitpage](https://pages.github.com)，相当于以上的所有东西都给你提供了，只需要你将静态文件上传即可；

使用Gitpage的过程如下：

- 在github上建立一个你自己帐户的仓库，比如github帐号为`xx`，创建一个 `xx.github.io`的仓库
- 然后将`hugo build`出来的`public`目录下的文件`push`至该仓库的`master`分支，只能是`master`
- 然后进行仓库配置的gitpage里面进行配置即可，参见(https://pages.github.com/#project-site)
- 官网里面也介绍的非常详细([https://pages.github.com](https://pages.github.com/))

### 脚本

每次发布我觉得太麻烦了，因为你的blog是一个仓库，而静态文件是另外一个仓库，所以我写了一个简单的脚本

```shell
echo "---------------- start --------------------"
git add .

git commit -am "commit message: $1"

git push origin master

echo "---------------- remove public-------------"
rm -rf public/* -y

echo "---------------- generate public-----------"
hugo

echo "---------------- cd   public---------------"
cd public

echo "---------------- commit public-------------"
git add .
git commit -am  "commit blog"

echo "---------------- push public---------------"
git push -f

echo "---------------- end  --------------------"
```

