---
date :  "2020-02-05T21:43:03+08:00" 
title : "k8s(二)––基础概念" 
categories : ["技术文章"] 
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

简称`deploy`，运行在

#### pod

#### replicationcontroller

#### service

