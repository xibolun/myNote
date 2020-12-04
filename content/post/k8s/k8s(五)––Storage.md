---

date :  "2020-02-14T13:44:57+08:00" 
title : "k8s(五)––Storage" 
categories : ["技术文章"] 
tags : ["k8s"] 
toc : true
---

### K8s数据卷

`docker`里面使用`Volume`进行挂载； `k8s`里面的数据卷集成了各种的存储系统-- [Types of Volumes](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types)；主要看一下`HostPath`、`EmtptyDir`，以及`PV/PVC`的使用和操作

### 本地存储

#### [EmptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)

随着`Pod`的创建而创建，删除而删除，适用于`Pod`之间的文件共享

创建一个`EmptyDir`类型的`Pod`

```yaml
## 一个count镜像，用于测试日志输出的过程
apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
  - name: count
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      i=0;
      while true;
      do
        echo "$i: $(date)" >> /var/log/1.log;
        echo "$(date) INFO $i" >> /var/log/2.log;
        i=$((i+1));
        sleep 1;
      done
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog
    emptyDir: {}
```

```shell
➜  k8s kubectl exec  counter -- ls /var/log
1.log
2.log
```

#### [HostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)

挂载卷在宿主机`Node`上面的挂载类型，当`Pod`被删除的时候，还可以被持久化下来；

```yaml
## 一个count镜像，用于测试日志输出的过程
apiVersion: v1
kind: Pod
metadata:
  name: counter
spec:
  containers:
  - name: count
    image: busybox
		## 省略了一下.....
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog
    hostPath:
      path: /tmp/log
```

```shell
[root@ops-pre-4-103 tmp]# ll /tmp/log/
total 8
-rw-r--r-- 1 root root 1541 Dec  3 14:30 1.log
-rw-r--r-- 1 root root 1729 Dec  3 14:30 2.log
```

### PV/PVC

有了PV，不管下层用的是什么存储类型，相当于给屏蔽掉底层，只对上层进行服务即可；用户管理员先对PV进行规划，然后开始创建一个一个地小块PVC，每个pvc与pv进行绑定；上层的pod可以使用创建出来的pvc，形成一套闭环的链路；删除的时候，会根据回收策略进行删除，是自行清理或者k8s自动清理等；

这篇 [搭建redis-cluster](https://cloud.tencent.com/developer/article/1392872)的文章里面使用`NFS`做为持久化的工具来实现`pv`、`pvc`

有几个注意的事项：

1. pv与pvc绑定可以使用相同的`StorageClass`，若不设置，那pvc就会找空的`StorageClass`的pv；
2. [Storage](https://kubernetes.io/docs/concepts/storage/storage-classes/#introduction)有一个属性为`volumeBindingMode`，默认为`Immediate`会立即绑定，若设置为`WaitForFirstConsumer`，则当有`Pod`使用此`pvc`的时候才会进行绑定；
3. 报错：`no volume plugin matched`；说明你没有对应的 [provisioner](https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner)；去搜索添加对应的`provisioner`即可，我使用的是`nfs`，需要安装 [nfs-client](https://github.com/kubernetes-retired/external-storage/tree/master/nfs-client)；然后再指定对应的配置；

可以看到使用nfs比较麻烦，流程如下

- 搭建nfs环境
- sa创建
- rbac: 创建
- nfs-client-provisioner创建
- storageclass创建
- 最后才是pv与pvc的创建，及其他所需要 pvc资源的创建；

