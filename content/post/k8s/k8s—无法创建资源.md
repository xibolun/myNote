---

date :  "2021-12-05T17:46:15+08:00" 
title : "k8s——无法创建Deployment" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
description: k8s deployment
---

### 现象

写了一个CRD文件，里面有一个deployment+service，但是service可以创建成功，deployment无法创建成功

```
# kubectl get svc -n idcos -o wide
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
cloud-act2-doc-srv   NodePort    10.233.32.94    <none>        80:32600/TCP   15m   app=cloud-act2-doc
```

```
# kubectl get deployment -n idcos cloud-act2-doc -o wide
NAME             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS       IMAGES                                               SELECTOR
cloud-act2-doc   0/1     0            0           15m   cloud-act2-doc   registry.idcos.com/cloudpower/cloud-act2-docs:v1.0   app=cloud-act2-doc
```

日志也无信息

```
# kubectl get event --all-namespaces -w
```

随便找了一个官方的deployment crd文件也无法创建

### 定位

创建不成功，大概率是网络的问题，看一下DOWN的网络节点

```
# ip link ls | grep DOWN
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
6: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
7: kube-ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
8: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
```

- docker0，用于docker与宿主机通信的
- kube-ipvs0：用于k8s nodes节点之间的能讲