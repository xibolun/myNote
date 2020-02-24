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

NodePod、ClusterIP、









