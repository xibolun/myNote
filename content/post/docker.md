+++
date = "2017-06-20T23:36:24+08:00" title = "Docker学习" categories = ["技术文章"] tags = ["docker"] toc = true
+++

date = "2017-06-20T23:36:24+08:00"
title = "Docker学习"

+++

Get Started
===========

command
-------

1.  docker --version : docker版本
2.  docker command --help : 查看某个命令的帮助
3.  docker-compose --version : docker compose版本
4.  docker-machine --version: docker machine版本
5.  docker version: 查看docker client和server的状态
6.  docker run -h='cmdb' --name cmdb -d -p 180:80 -p 122:22 dcosapp1.0
7.  docker save -o dcosapp.tar dcosapp1.0

镜像
----

-   docker pull ubuntu:14.04 : 下载ubuntu:14.04镜像
-   docker images : 列出镜像
-   docker images -q : 只列出镜像ID
-   docker images -f since=hello-world : -f 过滤出某些镜像；since/before
-   ​

容器
----

### 启动容器

1.  docker run -it ubuntu:14.04 : 启动一个容器
2.  docker run -itd ubuntu:14.04 : 启动一个detach的容器，可以使用docker
    attach或者docker exec重新连接
3.  docker run -it -n pengganyu : 启动容器时添加容器名称
4.  docker run -it -v /tmp ubuntu:14.04 : 创建容器时添加Volumn
5.  docker run -it -v /tmp:/tmp ubuntu:14.04 :
    创建容器时添加/tmp卷，同时连接host的/tmp目录，host的/tmp与容器里面的/tmp共享

### 其他

1.  docker create ubuntu:14.04 : 创建一个容器
2.  docker ps : 查看running状态的docker运行状态；
3.  docker ps -a : 查看所有的容器列表，包括没有运行的和已经Exited
4.  docker run -it ubuntu:14.04 /bin/bash :
    启动一个bash终端，退出则容器销毁
5.  docker exec -it de2ef4052dce /bin/bash: 进入某个docker容器
6.  docker rm bfa78720b949 : 删除某个容器，其中bfa78720b949为容器的ID号
7.  ctrl+d :
    退出容器，此时容器也就不再running了，若想重新再running，可以使用docker
    start bfa
8.  docker export de2ef4052dce &gt; test.tar : 将容器导出至tar
9.  docker import test.tar - test/ubuntu:v1.0 : 导入容器

数据管理
--------

### 创建docker与本地主机的共享

1.  docker run -it -v /tmp:/tmp ubuntu:14.04 :
    创建容器时添加/tmp卷，同时连接host的/tmp目录，host的/tmp与容器里面的/tmp共享
2.  第一个tmp为docker里面的数据卷，第二个/tmp为本机的/tmp目录
3.  本机目录必须为绝对路径

### 创建docker与其他docker的共享

1.  创建docker hf-csa-manager ： docker run -it -v hf-csa-manager --name
    hf-csa-manager ubuntu:14.04 /bin/bash
2.  创建docker hf-cmdb : docker run -it --volumes-from hf-csa-manager
    --name hf-cmdb ubuntu:14.04 /bin/bash
3.  两个docker的hf-csa-manager目录数据即可共享

网络配置
--------
