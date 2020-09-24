---
date :  "2020-02-12T14:27:40+08:00" 
title : "k8s(四)--Pod" 
categories : ["技术文章"] 
tags : ["k8s"] 
toc : true
---

### Pod[的生命周期](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

- Pending
- Running
- Succeeded
- Failed
- Unknown

### 探索Pod

建立一个模板

```
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: nginx
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```

创建pod，刚开始会创建中，过一会儿会变成running状态

```
[root@k8s-master ~]# kubectl apply -f hello.yaml 
[root@k8s-master ~]# kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-pod                1/1     Running   0          4m51
```

查看命令输出

```
[root@k8s-master ~]# kubectl logs myapp-pod
Hello Kubernetes!
```

进入pod

```
kubectl exec myapp-pod -it /bin/bash
```

查看pod描述信息

```
kubectl describe pod myapp-pod
```

删除pod

```
## 删除pod
kubectl delete pod myapp-pod
```

如果不知道怎么创建模板时的各种参数怎么办？

- 具体的参数列表可以查看：[pod-v1-core](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.17/#pod-v1-core)
- 也可以使用 `kubectl explain pod`命令进行说明，并且可以一直递归查看
  -  kubectl explain pod.metadata.....

为什么要创建模板？

- 这种方式叫声明式创建，可以重复使用啊，不用每次都写一大堆的命令
- 更容易做自动化的配置；

### Pod的特性

#### 探针

用于k8s探测pod是否处理living状态，主要有三种方式

- http get请求：判断http返回状态码
- tcp socket connection：tcp套接字尝试连接，类似ping命令
- exec command: 执行一个命令

### 问题

- pod重启了ip如何保持不变？
- 如果将pod里面的应用对外进行暴露
- 如何在多个pod间的负载均衡控制

