---
date :  "2020-02-16T22:11:21+08:00" 
title : "Lxc使用笔记" 
categories : ["技术文章"] 
tags : ["lxc"] 
toc : true
---

### 什么是LXC？

![lxc-logo](/img/lxc/lxc-logo.png)

LXC（Linux Container）的缩写，Linux操作系统级别的虚拟化技术，利用命名空间保证进程的隔离，及cgroup技术控制cpu\内存\硬盘IO\网络，为Linux内核操作系统虚拟化出一个用户空间的容器，里面包含着应用所需要的核心组件和一些基础的函数库，类似一个沙箱的环境；使Linux用户可以快速创建和管理容器环境；

使用LXC的好处

- 安全：最主要的是网络运行在容器里面，与外界保持隔离
- 隔离：传统模式安装应用之间存在互相干扰，因为在同一台设备上面会安装多个应用；使用lxc可以创建多个container，应用与应用之间完全隔离，这些应用可以按需绑定物理资源，像网络，存储，硬盘，cpu等等
- 透明：屏蔽掉底层的物理硬件和一些系统参数设置

### 环境搭建(centos7)

```
# yum -y install epel-release
## 最主要是安装前两个lxc lxc-template
# yum -y install lxc lxc-templates libcap-devel libcgroup busybox wget bridge-utils lxc-extra
```

`lxc-template`是一系列的容器模板，centos、oracle、ubuntu等等，类似docker的基础操作系统镜像

```
[root@k8s-master ~]# ll /usr/share/lxc/templates
总用量 372
-rwxr-xr-x 1 root root 10579 3月   8 2019 lxc-alpine
-rwxr-xr-x 1 root root 13537 3月   8 2019 lxc-altlinux
-rwxr-xr-x 1 root root 10839 3月   8 2019 lxc-archlinux
-rwxr-xr-x 1 root root  9677 3月   8 2019 lxc-busybox
-rwxr-xr-x 1 root root 29971 3月   8 2019 lxc-centos
-rwxr-xr-x 1 root root 29971 2月  15 15:14 lxc-centos.bak
-rwxr-xr-x 1 root root 10486 3月   8 2019 lxc-cirros
-rwxr-xr-x 1 root root 18342 3月   8 2019 lxc-debian
-rwxr-xr-x 1 root root 18064 3月   8 2019 lxc-download
-rwxr-xr-x 1 root root 49438 3月   8 2019 lxc-fedora
-rwxr-xr-x 1 root root 28253 3月   8 2019 lxc-gentoo
-rwxr-xr-x 1 root root 13965 3月   8 2019 lxc-openmandriva
-rwxr-xr-x 1 root root 13882 3月   8 2019 lxc-opensuse
-rwxr-xr-x 1 root root 35540 3月   8 2019 lxc-oracle
-rwxr-xr-x 1 root root 12233 3月   8 2019 lxc-plamo
-rwxr-xr-x 1 root root  6851 3月   8 2019 lxc-sshd
-rwxr-xr-x 1 root root 24133 3月   8 2019 lxc-ubuntu
-rwxr-xr-x 1 root root 11641 3月   8 2019 lxc-ubuntu-cloud
```

安装完成后，校验环境是否支持，主要检查：namespace、cgroups、misc、Checkpoint、restore是否都支持

```
# lxc-checkconfig
```

### 新建容器

```
## -n 名称  -t 模板名称
# lxc-create -n c1 -t centos
```

创建完成后，会提示密码内容和修改密码的方式

```
......
The temporary root password is stored in:

        '/var/lib/lxc/c1/tmp_root_pass'


The root password is set up as expired and will require it to be changed
at first login, which you should do as soon as possible.  If you lose the
root password or wish to change it without starting the container, you
can change it from the host by running the following command (which will
also reset the expired flag):

        chroot /var/lib/lxc/c1/rootfs passwd
```

查看密码，也可以直接修改密码；或者copy一个centos的模板，然后将里面的密码进行自己初始化

```
[root@k8s-master ~]# cat /var/lib/lxc/c1/tmp_root_pass 
Root-c1-VpZrdB
```

创建成功的容器目录在

```
/var/lib/lxc/c1
```

后台启动容器

```
 lxc-start -n c1 -d
```

进入容器

```
# 此种方式进入需要按Ctrl+a按两次；退出Ctrl+a q
lxc-console -n c1 -t 0
# 此种方式进入不需要输出用户名和密码，退出Ctrl+d
lxc-attach -n c1
```

### 常用命令

```
# 列出现在的容器
lxc-ls
# 查看运行的容器
lxc-ls --active
# 查看运行的容器
lxc-top
# 查看容器详情
lxc-info -n c1
# 停止容器，耗费时间有点长
lxc-stop -n c1
# 摧毁容器
lxc-destroy -n c1
# 冻结容器
lxc-freeze -n c1
# clone容器 clone的时候需要关闭容器
lxc-clone c1 centos_lxc_clone
# 为容器添加快照
lxc-snapshot -n c1
# 查看容器的快照，可以看到备份的时间，和存储的路径
# lxc-snapshot -L -n c1
snap0 (/var/lib/lxcsnaps/c1) 2020:02:16 23:49:59
# 用快照回滚容器
lxc-snapshot -r snap0 -n c1
```

### 网络配置

有两种方式配置，一种是借助`lxc-net`配置，一种是人工添加网卡，做桥接

### 其他设置

开机启动

```
# Enable autostart
lxc.start.auto = 1
```

设置挂载路径

```
# Bind mount system path to local path
lxc.mount.entry = /mnt mnt none bind 0 0
```

图形化管理界面

```
https://github.com/lxc-webpanel/LXC-Web-Panel
```

### 参考

- [lxc容器网络配置](https://www.thegeekdiary.com/how-to-set-external-network-for-containers-in-linux-containers-lxc/)