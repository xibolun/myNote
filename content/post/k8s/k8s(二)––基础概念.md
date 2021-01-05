---
date :  "2020-02-05T21:43:03+08:00" 
title : "k8s(二)––基础概念" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
---

### 部署第一个应用

首先创建一个`deployment`

```
[root@k8s-master ~]# kubectl create deploy nginx --image=nginx
```

查看一下`deployment`和`pod`的信息

```
[root@k8s-master ~]# kubectl get deploy -o wide
NAME    READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES   SELECTOR
nginx   0/1     1            0           2m13s   nginx        nginx    app=nginx
[root@k8s-master ~]# kubectl get pods -o wide
NAME                     READY   STATUS         RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
nginx-86c57db685-vjz8x   0/1     ErrImagePull   0          18s   10.244.1.5   k8s-node2   <none>           <none>
[root@k8s-master ~]# kubectl get replicaset -o wide
NAME               DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES   SELECTOR
nginx-86c57db685   1         1         1       11m   nginx        nginx    app=nginx,pod-template-hash=86c57db685
```

稍等片刻，等服务启动起来，请求一下

```
[root@k8s-master ~]# curl 10.244.1.5
```

还可以另起一个窗口启动一个代理，通过`POD_NAME`访问

```
[root@k8s-master ~]# kubectl proxy
Starting to serve on 127.0.0.1:8001

```

在原窗口当中执行，其中`nginx-86c57db685-vjz8x`是pod的名称

```
curl http://localhost:8001/api/v1/namespaces/default/pods/nginx-86c57db685-vjz8x/proxy/
```

### 伸缩

扩容与缩容都使用`scale`命令，通过`replicas`来控制pod的数量

```
[root@k8s-master ~]# kubectl scale deploy/nginx --replicas=3
deployment.apps/nginx scaled
[root@k8s-master ~]# kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-86c57db685-7m6dp   1/1     Running   0          15m
nginx-86c57db685-vjz8x   1/1     Running   0          23h

```

### 组件

![k8s component](https://d33wubrfki0l68.cloudfront.net/7016517375d10c702489167e704dcb99e570df85/7bb53/images/docs/components-of-kubernetes.png)

[组件](https://kubernetes.io/docs/concepts/overview/components/) 分为三大类：k8s组件、node组件、插件

#### K8s组件

- kube-controller-manager
- cloud-controller-manager
- kube-api-server
- etcd
- kube-scheduler

#### Node组件

- kubelet
- kube-proxy
- container-runtime

#### 插件

- DNS
- WebUI （`minikube dashboard`）
- Container Resource Monitoring
- Cluster-level Loggin

### 概念

### namespace

命名空间，隔离不同的`deployment`、`pod`、`service`、`replicaset`，相当于租户的概念；

命名空间的 操作

```
## 创建
[root@k8s-master ~]# kubectl create namespace aa

## 查看
[root@k8s-master ~]# kubectl get ns

## 删除，注意删除的时候会将此命名空间下面的所有资源都删除
[root@k8s-master ~]# kubectl delete ns/aa
```

#### deployment

简称`deploy`；

生命周期：`progressing`、`complete`、`fail to progress`

#### pod

用于存放`container`的容器组，是k8s的最基本单元，一个`pod`里面可以有多个容器；并且可以包含不同的容器；存储卷，网络服务，普通镜像等；一个`node`上面可以有多个`pod`

#### node

node是k8s里面的虚拟机或物理机，是计算节点；承载着N个pod；master会根据资源的(cpu、内存、硬盘、负载等)指标去计算，指定需要创建的`pod`在哪个节点上面；

#### replication controller

`pod`副本控制器，用于根据`CRD`文件当中指定参数控制`pod`的数量和状态；可以用于弹性伸缩、故障处理、升级、迁移等；

#### service

`cluster`与宿主机网络是不通的，因此需要`proxy`，`k8s`也提供了`kubectl proxy`，也可以使用`service`进行操作；将一组的pod进行统一的管理和适配

#### ingress/egress

`pod`集群的入流量称为`ingress`，出流量为`egress`；可以通过配置策略来达到这样的限制的效果；

基于以上两个概念就会有了入流量的控制器`ingressController`；



