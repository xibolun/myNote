---
date :  "2019-10-08T10:21:40+08:00" 
title : "SaltStack(四)Grains&Pillar" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

### [Grains](https://docs.saltstack.com/en/latest/topics/grains/index.html)

minion的静态属性信息，分为`core grains`和`custom grains `

#### core grains

查看grains列表

```
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' grains.items
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' grains.ls   
```

获取某个属性

```
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' grains.item zmqversion
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    ----------
    zmqversion:
        4.1.4
```

```
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' grains.get zmqversion
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    4.1.4
```

#### custom grains

自定义grains有多个地方可以定义:

```
1. Core grains.
2. Custom grains in /etc/salt/grains.
3. Custom grains in /etc/salt/minion.
4. Custom grain modules in _grains directory, synced to minions.
```

`/etc/salt/minion`配置文件当中

```
# Custom static grains for this minion can be specified here and used in SLS
# files just like all other grains. This example sets 4 custom grains, with
# the 'roles' grain having two values that can be matched against.
grains:
  roles:
    - webserver
    - memcache
  deployment: datacenter4
  cabinet: 13
  cab_u: 14-15
```

配置完成后，需要刷新一下

```
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' saltutil.sync_grains
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' grains.get roles       
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    - webserver
    - memcache
```

> Tips: 若配置错误，minion会挂掉

`/etc/salt/grains`配置，简单配置了一个app信息

```
app:
  loc: hangzhou
  name: ZHJY
```

```
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' saltutil.sync_grains
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' grains.get app      
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    ----------
    loc:
        hangzhou
    name:
        ZHJY
```

#### [Pillar](https://docs.saltstack.com/en/latest/topics/pillar/index.html#storing-static-data-in-the-pillar)

存放在master端的数据结构信息，由`/srv/pillar/top.sls`文件进行统管控制

```
base:
  '*':
    - log
```

添加了一个`log`的配置在`/etc/pillar/log.sls`

```
# /srv/pillar/log.sls
# 日志配置
Logger:
  # 日志存放路径，当前目录的log文件夹
  Path: "/tmp/cloudboot/logs"
  # 日志打印等级，[debug, info, warn, err, off]
  Level: "debug"
  # 最大存放时间，7天，超过7天的日志会删除
  MaxAge: 7
  # 日志分割时间，24小时，日志以1天为单位分割，一天一个文件
  RotationTime: 24
```

查看pillar列表

```shell
➜  pillar sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' pillar.items
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    ----------
    Logger:
        ----------
        Level:
            debug
        MaxAge:
            7
        Path:
            /tmp/cloudboot/logs
        RotationTime:
            24
```

刷新`pillar`

```
➜  salt sudo salt '*' saltutil.refresh_pillar
```

使用`jinjia`动态参数配置





### 通用

输出为`json`的时候数据结果不会进行合并，添加`static`参数

```
➜  ~ sudo salt '*' grains.get fqdn_ip4 --out=json         
{
    "AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6": [
        "172.18.0.2"
    ]
}
{
    "E84B4F5F-0000-0000-BBD1-FA294FBCB7D5": [
        "172.18.0.3"
    ]
}
➜  ~ sudo salt '*' grains.get fqdn_ip4 --out=json --static
{
    "AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6": [
        "172.18.0.2"
    ], 
    "E84B4F5F-0000-0000-BBD1-FA294FBCB7D5": [
        "172.18.0.3"
    ]
}

```

