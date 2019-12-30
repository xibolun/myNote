---
date :  "2019-10-16T09:07:03+08:00" 
title : "SaltStack(六)任务管理" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

### Job管理

salt在执行命令的时候会生成一个`JobID`，存放在`/var/cache/salt/{master|minion}/proc`下面

```shell
➜  ~ tree /var/cache/salt/master -L 1
/var/cache/salt/master
├── file_lists
├── jobs  ## 历史job数据信息
├── minions
├── proc ## 当前job数据信息
├── queues
├── roots
├── syndics
└── tokens
```
`minion`

```shell
[root@minion2 ~]# tree /var/cache/salt/minion/ -L 1
/var/cache/salt/minion/
|-- accumulator
|-- extmods
|-- files  ## master /srv/salt/下的文件同步
|-- highstate.cache.p
|-- module_refresh
└── proc  ## 当前job数据信息
```

查看正在运行的job

```shell
➜  sudo salt-run jobs.active
20191016092026294806:
    ----------
    Arguments:
    Function:
        state.highstate
    Returned:
    Running:
        |_
          ----------
          AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
              3522
        |_
          ----------
          E84B4F5F-0000-0000-BBD1-FA294FBCB7D5:
              834
    StartTime:
        2019, Oct 16 09:20:26.294806
    Target:
        *
    Target-type:
        glob
    User:
        sudo_admin
```

salt-run Job相关操作

```shell
➜  ~ sudo salt-run jobs.exit_success 20191016092026294806  ## 查看job是否执行成功
➜  ~ sudo salt-run jobs.active   ## 查看正在运行的ob
➜  ~ sudo salt-run jobs.list_job 20191016092026294806  ## 查看某个job的信息
➜  ~ sudo salt-run jobs.list_jobs ## 查看所有的job
➜  ~ sudo salt-run jobs.lookup_jid 20191016092026294806 ## 查看某个job的详情，与list_job有不同
➜  ~ sudo salt-run jobs.print_job 20191016092026294806  ## 打印job详情，与list_job功能相同
```

> 所有的Job操作：https://docs.saltstack.com/en/latest/ref/runners/all/salt.runners.jobs.html

#### saltutil管理Job

`salt-master`run一个sleep的命令，请注意超时时间的设置

`salt '*' cmd.run 'sleep 30'`

```
salt '*' saltutil.running  ##查看正在running的job，可以拿到jid
salt '*' saltutil.find_job 20191209234219896309 ## 查看jid
salt '*' saltutil.signal_job 20191209234219896309 9 ## 向job发送信号
salt '*' saltutil.term_job  20191209234219896309 ## 终止job
salt '*' saltutil.kill_job  20191209234219896309 ## 杀掉job
```

### 定时Job

定时job的应用场景：

- 分布式架构下文件同步、下发
- 监控系统当中的定时巡检，采集
- 配管系统当中的配置变更、修改；配置一致性检查
- .....

#### 如何使用

- 在配置文件当中打开；一分钟执行一个`file_roots`下面的`schedule`

```shell
# The loop_interval option controls the seconds for the master's maintenance
# process check cycle. This process updates file server backends, cleans the
# job cache and executes the scheduler.
#loop_interval: 60
```

- 使用`Pillar`；在`master` 添加配置，然后刷新同步至`minion` ,`saltutil.refresh_pillar`
- 使用 [`schedule state`](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.schedule.html#module-salt.states.schedule) or [`schedule module`](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.schedule.html#module-salt.modules.schedule)

#### Pillar实战下发文件

将`/srv/salt/resource/dove.jpg`下发至`minion`的`/home/www/resource/dove.jpg`

创建文件

```shell
# /srv/salt/resource.sls
/home/www/resource/dove.jpg:
  file:
    - managed
    - source: salt://resource/dove.jpg
```

 添加定时模块`schedule.sls`

```shell
# /srv/pillar/schedule.sls
## 每5s执行 resource.sls
schedule:
  job1:
    function: state.sls
    seconds: 5
    args:
      - resource
```

将`schedule.sls`添加至`/srv/pillar/top.sls`

```shell
base:
  '*':
    - schedule
```

刷新`pillar`至`minion`

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' saltutil.refresh_pillar        
```

将文件删除后，等5s再查看文件是否同步成功

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'rm -f /home/www/resource/dove.jpg'
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'ls  /home/www/resource/dove.jpg'  
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    ls: cannot access /home/www/resource/dove.jpg: No such file or directory
ERROR: Minions returned with non-zero exit code
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'ls  /home/www/resource/dove.jpg'
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    /home/www/resource/dove.jpg
```

#### 定时模块

帮助文档

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' schedule -d
```

```shell
salt '*' schedule.list  ## 定时列表
salt '*' schedule.add job1 function='test.ping' seconds=3600 ##添加job
salt '*' schedule.build_schedule_item job1 function='test.ping' seconds=3600 ## build job
salt '*' schedule.delete job1 ## 删除job
salt '*' schedule.disable ## 关闭所有job
salt '*' schedule.disable_job job1 ## 关闭指定job
salt '*' schedule.enable ## 打开所有job
salt '*' schedule.enable_job job1 ## 打开指定job
salt '*' schedule.is_enabled name=job_name ## 判断job是否被打开
salt '*' schedule.show_next_fire_time job_name ## 查看job的下一执行时间
salt '*' schedule.run_job job1 force=True ## run一个job
salt '*' schedule.purge ## 清空job
```

> 1. schedule的state命令不能操作pillar模式的任务
> 2. 这些命令都是针对于minion而言

 定时的其他用法：[salt.state.schedule](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.schedule.html)、[jobs](https://docs.saltstack.com/en/latest/topics/jobs/)

#### 定时模块实战下发文件

具体用法如下：

```shell
salt '*' schedule.add job_name function='xxxx' job_args="['xxxxx']" seconds=60
```

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' schedule.add job3 function='state.sls' job_args="['resource']" seconds=5
```

为避免与`pillar`进行重复，可以先将`pillar`的进行移除，由于无法使用`state.schedule`删除，所以删除`/srv/pillar/top.sls`里面的`schedule`，然后再刷新`pillar`

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' saltutil.refresh_pillar
```

再次查看`schedule.list`就只有一个下发文件的`job3`

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' schedule.list          
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    schedule:
      job3:
        args:
        - resource
        enabled: true
        function: state.sls
        jid_include: true
        maxrunning: 1
        name: job3
        seconds: 5
```

删除`minion`的文件，然后再查看

```shell
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'rm -f /home/www/resource/dove.jpg'
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'ls  /home/www/resource/dove.jpg'  
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    ls: cannot access /home/www/resource/dove.jpg: No such file or directory
ERROR: Minions returned with non-zero exit code
➜  ~ sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'ls  /home/www/resource/dove.jpg'
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    /home/www/resource/dove.jpg
```

