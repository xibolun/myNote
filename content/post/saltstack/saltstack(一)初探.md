---
date :  "2019-09-27T16:37:18+08:00" 
title : "SaltStack(一)初探" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

## SaltStack初探 ##

### Docker环境搭建

参考github上面的[salt-docker-demo](https://github.com/gtmanfred/salt-docker-demo)

master配置的log修改为Info，重启即可使用

```shell
[root@salt system]# cat /etc/salt/master
...
log_level: info
....
[root@salt system]# systemctl restart salt-master.service 
```

由于是docker环境，依赖安装的不完全，像`ip`，`ifconfig`都没有.... 

### 节点管理 ###

ping测试

```shell
[root@salt system]# salt '*' test.ping
minion2:
    True
minion1:
    True
```

查看minion的状态

``` shell
[root@salt system]# salt-run manage.status
down:
up:
    - minion1
    - minion2
```

### 执行命令 ###

操作命令的格式如下

``` shell
Usage: salt [options] '<target>' <function> [arguments]                        
```
- `options`的使用比较简单，支持超时时间、配置信息等
- `target`就是目标的minion列表，所有的就是*，多个就是minion的上报主键逗号分隔
- `function`是salt的一些内置的模块列表，`test.ping`，`cmd.run`等； `sys.list_modules`列出所有的模块
- `arguments`模块所需要的函数

```shell
[root@salt system]# salt 'minion1' sys.list_modules | wc -l
147
## 所有的函数
[root@salt system]# salt 'minion1' sys.list_functions | wc -l    
1548
```

[salt-module-index](https://docs.saltstack.com/en/latest/salt-modindex.html)：salt所有的moduels

#### 执行命令

执行命令

```
➜  ~ sudo salt '*' cmd.run 'ls /tmp'
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    bootstrap-salt.log
    ks-script-h2MyUP
    yum.log
E84B4F5F-0000-0000-BBD1-FA294FBCB7D5:
    bootstrap-salt.log
    ks-script-h2MyUP
    yum.log
```

安装软件，调用`pkg.install`

```
[root@salt system]# salt '*' pkg.install net-tools
```

下发文件

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cp.get_file salt://ping.sls /tmp          
```

> `salt://`是配置文件当中的`/srv/salt`目录

查看IP，调用`cmd.run`模块

```shell
[root@salt system]# salt '*' cmd.run 'ifconfig | grep inet'
minion2:
            inet 172.18.0.3  netmask 255.255.0.0  broadcast 172.18.255.255
            inet 127.0.0.1  netmask 255.0.0.0
minion1:
            inet 172.18.0.4  netmask 255.255.0.0  broadcast 172.18.255.255
            inet 127.0.0.1  netmask 255.0.0.0
```



### 参考 ###

  * [一篇salt的文章](http://ohmystack.com/articles/) 
  * [salt-in-10-minutes](https://docs.saltstack.com/en/latest/topics/tutorials/walkthrough.html#salt-in-10-minutes)

