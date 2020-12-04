---
date :  "2020-02-06T21:43:03+08:00" 
title : "k8s(三)––Service" 
categories : ["技术文章"] 
tags : ["k8s"] 
toc : true
---

### Service的作用

为什么要使用service

首先需要理解一下集群里面的一些IP分类：

- nodeIP: 集群当中会有许多的node，每一个node都会有自己的IP；包括master的IP，因为master也是node
- podIP: 每一个node上面会有多个pod，每一个pod也会有自己的IP;
- serviceIP: 是pods节点上层的一层抽象，这个IP是一个虚拟IP，可以访问，但是ping不通

一个node上面的pods会被删除，新增，导致IP会存在变化，使用service可以进行统一封装，类似nginx做一层代理，service做为统一的入口访问，可以做负载和转发，所以就有了上面的serviceIP；

### Service的模式

- NodePod：可以指定在集群内访问，同时也可以指定集群外的访问；只有一个局限，那便是端口号有一个范围 `30000~32767`，可以通过`http://<KUBERNETES_MASTER>:32600`进行访问

```
➜  k8s kubectl get svc -n idcos -o wide
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
cloud-act2-doc-srv   NodePort    10.233.33.230   <none>        80:32600/TCP   4s    app=cloud-act2-doc
```

- ClusterIP：默认的`svc type`，只能在集群内访问，会自动创建`endpoints`进行关联

```shell
➜  k8s kubectl get svc -n idcos -o wide
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
cloud-act2-doc-srv   ClusterIP   10.233.43.198   <none>        80/TCP    9s    app=cloud-act2-doc
```

```shell
➜  k8s kubectl get endpoints -n idcos -o wide
NAME                 ENDPOINTS           AGE
cloud-act2-doc-srv   10.233.105.49:80    51s
```

- LoadBalancer：会分配给`svc`一个虚拟的`CLUSTER_IP`，同时也会暴露一个`NodePort`供外部进行访问；

```shell
➜  k8s kubectl get svc -n idcos
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
cloud-act2-doc-srv   LoadBalancer   10.233.38.230   <pending>     80:32077/TCP   8s
```

### Headless Service

无IP的那些`service`称为 [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) ，用于那些不需要服务发现的`svc`

### 参考

- [jimmysong的blog](https://jimmysong.io/kubernetes-handbook/guide/accessing-kubernetes-pods-from-outside-of-the-cluster.html)







