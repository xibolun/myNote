---
date :  "2019-11-07T16:37:18+08:00" 
title : "SaltStack(十)salt-event" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

## SaltEvent

在salt的架构里面有一个叫[sal-event](https://docs.saltstack.com/en/latest/topics/event/events.html)的东西，可以记录着`master`与 `minion`通讯时的一些事件信息；

### 如何监听

监听有两种方式；一种是通过命令行，一种是通过代码监听 `socket`

#### 代码方式

```python
import salt.config
import salt.utils.event

opts = salt.config.client_config("/etc/salt/master")

event = salt.utils.event.get_event(
    "master", sock_dir=opts["sock_dir"], transport=opts["transport"], opts=opts
)

data = event.get_event()
```

#### 命令方式

```shell
salt-run state.event pretty=True
```

这时会进入一个等待的状态，监听事件列表；重启一下 `salt-minion`，将输出如下信息；

```shell
minion/refresh/10.0.2.38        {"Minion data cache refresh": "10.0.2.38", "_stamp": "2020-10-26T09:02:24.924301"}
minion_start    {"pretag": null, "cmd": "_minion_event", "tag": "minion_start", "data": "Minion 10.0.2.38 started at Mon Oct 26 17:02:25 2020", "id": "10.0.2.38", "_stamp": "2020-10-26T09:02:25.446265"}
salt/minion/10.0.2.38/start     {"pretag": null, "cmd": "_minion_event", "tag": "salt/minion/10.0.2.38/start", "data": "Minion 10.0.2.38 started at Mon Oct 26 17:02:25 2020", "id": "10.0.2.38", "_stamp": "2020-10-26T09:02:25.454942"}
```

### 事件解释

```go
type SaltEvent struct {
	Tag  string                 `json:"tag"`
	Data map[string]interface{} `json:"data"`
}
```

- `tag`标志着事件的类型，常用的`tag`[列表](https://docs.saltstack.com/en/latest/topics/event/master_events.html#authentication-events)
- `Data`里面存放着数据信息

### 应用

可以使用这个特性来做一些自主的触发提示；比如说有新的主机连接过来了、新的job返回了，用来做监听事件非常的不错。