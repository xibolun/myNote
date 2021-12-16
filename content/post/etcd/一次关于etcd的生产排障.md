---
date :  "2021-12-16 12:50:35+08:00"
title : "一次关于etcd故障处理" 
categories : ["etcd"] 
tags : ["etcd",'排障'] 
toc : true
---

## 一次关于etcd故障处理

### 现象

- 任务下发配置不成功

### 链路整理

- web -> 服务端放参数至 ->  etcdserver -> 远程机接收参数信息 -> 远程机执行命令

### 问题解决

- 第一波观察日志未果

- 怀疑证书问题，因为项目已经5年过去了，当时生成`etcd`证书确实使用了默认5年的配置，先把etcd证书更新了一版本，生成方法

```
https://github.com/coreos/docs/blob/master/os/generate-self-signed-certificates.md
```

- 生成证书各端更新完后，`etcd`本身检查没有问题，发现服务端日志里面存在异常

```
2021-12-15T21:51:06.710+0800    ERROR   node/server.go:57       context deadline exceeded
vendor/go.uber.org/zap.Stack
        /var/lib/workspace/cronsun/qstack/cronsun/src/vendor/go.uber.org/zap/field.go:191
vendor/go.uber.org/zap.(*Logger).check
        /var/lib/workspace/cronsun/qstack/cronsun/src/vendor/go.uber.org/zap/logger.go:301
vendor/go.uber.org/zap.(*Logger).Check
        /var/lib/workspace/cronsun/qstack/cronsun/src/vendor/go.uber.org/zap/logger.go:172
vendor/go.uber.org/zap.(*SugaredLogger).log
        /var/lib/workspace/cronsun/qstack/cronsun/src/vendor/go.uber.org/zap/sugar.go:233
vendor/go.uber.org/zap.(*SugaredLogger).Errorf
        /var/lib/workspace/cronsun/qstack/cronsun/src/vendor/go.uber.org/zap/sugar.go:148
github.com/shunfei/cronsun/log.Errorf
        /var/lib/workspace/cronsun/qstack/cronsun/src/github.com/shunfei/cronsun/log/log.go:39
main.main	
```

查询发现，etcd 3.3版本升级完证书存在问题，需要升级etcd到3.4版本，想想算了，证书过期了，还可以使用，将就一下

```
https://github.com/sensu/sensu-go/issues/3792
```

观察日志发现存在如下异常

```
2021-12-15T22:01:39.392+0800    WARN    cronsun/job.go:460      GetJobs get etcd error rpc error: code = ResourceExhausted desc = grpc: received message larger than max (4206331 vs. 4194304)
2021-12-15T22:01:39.392+0800    WARN    node/node.go:131        load jobs get jobs err rpc error: code = ResourceExhausted desc = grpc: received message larger than max (4206331 vs. 4194304)
```

`etcd server`当中存在起过4M的消息，而client无法消费，可以通过设置:`MaxCallRecvMsgSize`来实现；查看`client.Config`发现由于项目太老，文件缺少这两个参数，项目本身还使用`govendor`维护，而前人已经离职不知去向。

将代码下载下来，使用`govendor fetch github.com/coreos/etcd/clientv3`无效

于是粗暴一点，直接下载`etcd`源码，切换至`git checkout v3.3.0-rc.4`版本（由于etcd server使用的也是3.3.0，所以不敢升级太高版本），将源码`copy`至`vendor/github.com/coreos/`目录下，重新编译，失败；

异常如下：

```
/private/tmp/qstack/cronsun/src/vendor/golang.org/x/net/http2/frame.go use of vendored package not allowed
```

查看官网源码，得知，`x/net`包已经使用了`gomod`，https://cs.opensource.google/go/x/net/+/master:go.mod`，当前编译环境`go version`为`1.16`

重新下载`golang 1.11`配置`GOPATH`编译通过，发版重启后服务正常运行；



### 总结

- `etcd`本身代码存在许多的问题，包括证书、包管理等，使用时需要情重，最好使用新版本来解决；
- `govendor`的项目最好能升级至`gomod`，否则会给别人留下许多的坑
- 业务有时也需要备用方案