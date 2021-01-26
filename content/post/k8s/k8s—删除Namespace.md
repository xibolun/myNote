---
date :  "2020-12-03T14:21:20+08:00" 
title : "k8s—强制删除namespace" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
description: k8s namespace Terminating
---

在学习`Operator`的时候，使用`kubectl`创建了一个`namespace`，但是删除的时候无法被删除，状态一直是Terminating；

```shell
➜  ~ kubectl get ns  pgy
NAME   STATUS        AGE
pgy    Terminating   13d
```

强制删除也不行，

```shell
➜  ~ kubectl delete ns  pgy  --force --grace-period=0
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
namespace "pgy" force deleted
```

查了一下，发现了一些原因；

```
➜  ~ kubectl get ns pgy -o json
```

```json
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "creationTimestamp": "2020-12-30T06:55:43Z",
        "deletionTimestamp": "2020-12-30T06:55:56Z",
        "name": "pgy",
        "resourceVersion": "28873309",
        "selfLink": "/api/v1/namespaces/pgy",
        "uid": "1a281f10-bc1c-46ef-8c92-db6b865c7293"
    },
    "spec": {
        "finalizers": [
            "kubernetes"
        ]
    },
    "status": {
        "phase": "Terminating"
    }
}
```

里面的这个`finalizers`不为空，导致无法删除，查了一下资料 [NamespaceSpec v1 core Spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#namespacespec-v1-core)；这个参数的意义乃是说，只有其为空的时候，才会被删除，[它存在的目的](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/namespaces.md#finalizers)

那怎么删除呢？将其更新为空即可，使用其API接口，添加k8s证书即可

```shell
curl --location --request PUT 'https://10.0.4.175:6443/api/v1/namespaces/aa/finalize' \
--header 'Content-Type: application/json' \
--data-raw '{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "creationTimestamp": "2020-12-30T06:55:43Z",
        "deletionTimestamp": "2020-12-30T06:55:56Z",
        "name": "pgy",
        "resourceVersion": "28873309",
        "selfLink": "/api/v1/namespaces/pgy",
        "uid": "1a281f10-bc1c-46ef-8c92-db6b865c7293"
    },
    "spec": {
        "finalizers": [
        ]
    },
    "status": {
        "phase": "Terminating"
    }
}'
```

