---
date :  "2019-09-29T22:52:49+08:00" 
title : "SaltStack(二)Mac环境搭建" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

## Mac OS本机SaltStack环境搭建

在mac os下部署一个master，并利用两个salt-minion的docker容器搭建一个本机版本的saltstack环境

### Salt安装及文件说明

#### 检查saltstack版本

minions版本号为`2019.2.1`，那么salt-master的版本号不能低于`2019.2.1`

```shell
[root@minion1 ~]# salt-minion -V
/usr/lib/python2.7/site-packages/salt/scripts.py:198: DeprecationWarning: Python 2.7 will reach the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 won't be maintained after that date.  Salt will drop support for Python 2.7 in the Sodium release or later.
Salt Version:
           Salt: 2019.2.1
```

brew仓库里面的saltstack，当前为`2019.2.0`所以不使用brew安装，使用[pkg安装](https://docs.saltstack.com/en/latest/topics/installation/osx.html#installation-from-the-official-saltstack-repository)

```shell
➜  ~ brew cat saltstack                                                                                               
class Salt < Formula
  include Language::Python::Virtualenv
                                                           
  desc "Dynamic infrastructure communication bus"                                                                                                                                                                                           
  homepage "https://s.saltstack.com/community/"                                                                       
  url "https://files.pythonhosted.org/packages/41/d4/7f6d6bb139506741771ff9feb8429d5a5ed860de9ab5a358e771e8cc3b76/salt-2019.2.0.tar.gz"
  sha256 "5695bb2b3fa288bcfc0e3b93d9449afd75220bd8f0deefb5e7fc03af381df6cd"
```

安装完成目录结构

```shell
➜  ~ tree /etc/salt 
/etc/salt
├── master
├── master.dist
├── minion
├── minion.d
├── minion.dist
├── minion_id
```

启动方式；使用`info`的log级别后台启动，具体参数可以`help`看一下

```shell
➜  ~ sudo salt-master -l info -d
```

### Minion配置修改

查看minion uuid，由于两个容器使用了同一镜像，所以uuid相同

```shell
[root@minion2 /]# cat /sys/class/dmi/id/product_uuid 
E84B4F5F-0000-0000-BBD1-FA294FBCB7D5
[root@minion1 ~]# cat /sys/class/dmi/id/product_uuid 
E84B4F5F-0000-0000-BBD1-FA294FBCB7D5
```

查看mac本机IP，做为salt-master的IP

```shell
➜  ~ ifconfig
.........192.168.1.228
```

修改minion配置，保证两个minion的uuid不唯一；

```shell
[root@minion1 ~]# cd /etc/salt/minion.d/
[root@minion1 minion.d]# vi minion.conf 
master: 192.168.1.228
id: E84B4F5F-0000-0000-BBD1-FA294FBCB7D5
[root@minion1 minion.d]# systemctl restart salt-minion.service
```

> 也可以直接修改/etc/salt/minion文件，将master和id修改即可

`minion`有可能连接了其他的master信息，清空`master`的`pub-key`

```shell
> /etc/salt/pki/minion/minion_master.pub
```

重启服务

```shell
systemctl status salt-minion.service
```

mac下查看配置是否成功

```shell
➜  ~ sudo salt-key -L                                    
Accepted Keys:
Denied Keys:
Unaccepted Keys:
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6
E84B4F5F-0000-0000-BBD1-FA294FBCB7D5
Rejected Keys:
```

接受minions

```shell
➜  ~ sudo salt-key -A
The following keys are going to be accepted:
Unaccepted Keys:
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6
E84B4F5F-0000-0000-BBD1-FA294FBCB7D5
Proceed? [n/Y] y
Key for minion AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6 accepted.
Key for minion E84B4F5F-0000-0000-BBD1-FA294FBCB7D5 accepted.
```

执行命令测试

```shell
➜  ~ sudo salt '*' test.ping
E84B4F5F-0000-0000-BBD1-FA294FBCB7D5:
    True
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    True
```

### 目录说明

```
/etc/salt
├── master   ## master配置
├── master.dist 
├── minion  ## minion server配置
├── minion.d ## minion节点配置
│   └── _schedule.conf
├── minion.dist 
├── minion_id ## minion的ID
└── pki ##公钥
```

