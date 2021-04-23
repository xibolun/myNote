---
date :  "2020-02-18 16:31:49+08:00"
title : "k8s(七)––Dashboard" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
---

## K8s(七)—Dashboard

Dashboard是K8s的管理界面，发行版本列表为：[dashbaord/releases](https://github.com/kubernetes/dashboard/releases)；主要是安装完成之后访问不了，所以整理一下

### 安装

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

- 若服务器网络不通，可以先将文件进行下载，然后进行安装
- 若镜像没有，需要将镜像先拉下来，然后再使用

### 访问

访问需要起动proxy， [官网](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)的教程里面是这样的

```shell
kubectl proxy
```

若想要远程访问，则使用如下命令，直接授权所有主机，IP，并且后台运行；

```shell
kubectl proxy --address='0.0.0.0' --accept-hosts='^\*$' &
```

访问地址：

```shell
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

若远程访问，修改一下IP即可；

### 登陆

登陆有两种方式，token或者认证文件；

token生成

```shell
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/kubernetes-dashboard -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

其中`kubernetes-dashboard`是在安装的文件里面指定的`serviceAccount`

### 问题

你可能会遇到如下问题：

-  遇到 [Login Not avaiable](https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md#login-not-available)的情况
- 登陆没有反应

原因原是，因为你没有证书，访问地址不安全，同时这个服务是ClusterIP，login成功之后，无法获取准确的跳转地址；

解决方法，将`kubernetes-service`服务修改为`NodePort`，待`service`重启完成后，看看`Pod`落到哪个`Node`上面

```shell
# kubectl -n kubernetes-dashboard  describe pod kubernetes-dashboard-78c79f97b4-5hjlc  | grep Node
Node:         jjh-db-test2/10.20.97.39
Node-Selectors:              kubernetes.io/os=linux
```

然后查看`service`的端口号：

```shell
kubectl -n kubernetes-dashboard  get service kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.110.60.112   <none>        443:31756/TCP   38m
```

访问： https://10.20.97.39:31756

> 若为chrome浏览器，不安全的情况下，请在页面所在的屏幕里面按： this is unsafe
>
> 不用怀疑，考验你的盲打能力

### 参考

- [访问K8s Dashboard的几种方式](https://segmentfault.com/a/1190000023130407)
