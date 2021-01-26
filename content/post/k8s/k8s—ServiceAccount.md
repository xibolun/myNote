---

date :  "2020-03-09T21:50:12+08:00" 
title : "k8s––ServiceAccount" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
---

### ServiceAccount

`ServiceAccount`也是一种资源，可以使用`kubectl`进行生命周期的管理，同时也是做为`API`认证的的一种方式；在每个`namespace`下面都会默认创建一个`default`的`ServiceAccount`，同时每创建一个`pod`都会将`servcieaccount`进行挂载

查看`default serviceaccount`,每个`serviceaccount`里面都会有一个`secret`

```shell
[root@ops-pre-4-175 ~]# kubectl describe serviceaccount default -n idcos
Name:                default
Namespace:           idcos
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   default-token-5tjh4
Tokens:              default-token-5tjh4
Events:              <none>
```

查看`secret`会发现里面有三部分组成，`namespace`、`token`、`CA证书`

```shell
[root@ops-pre-4-175 ~]# kubectl describe secrets default-token-5tjh4 -n idcos
Name:         default-token-5tjh4
Namespace:    idcos
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 374ed7a5-1e1e-4914-a77a-5e00c63dcc75

Type:  kubernetes.io/service-account-token

Data
====
namespace:  5 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IjVLYlJRZnZFc0M5UGNsTlBIYWtTS1ZvaUt0eGZJdkJsaGxjLXQ1N3JYQnMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJpZGNvcyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkZWZhdWx0LXRva2VuLTV0amg0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImRlZmF1bHQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIzNzRlZDdhNS0xZTFlLTQ5MTQtYTc3YS01ZTAwYzYzZGNjNzUiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6aWRjb3M6ZGVmYXVsdCJ9.G6P7M1frjcPRu573bJfnIFD6iS3UOQ1uHwCKc5QGc6mnymv5AciauaCJwUNh_2qNIXbdLS0TwooST3k7AFkTIM72mGuYaDa73jJ5kU871buMhZmOtXSqWJGFbhhzgVBOkMT8uFCcpC0IdkZU9FoFnSmrtNjVF1fZdeqZO7MBWrW0q2p4QKGv1Io4qnADbiv3wE5BxUYMyIcEhz9tczvf_GZbY_W9x_QeY0-w-3rkVFQqNZpd2b1XAKgNMil9CVCVpKGE9YYuUbGseaoBSQDM4jOwu5LSNhFTVbHC9ACp3lWAd5KLbdhRX-QU8yIyU1IkMNR3EK8EnywY8AtE_1Pjmg
ca.crt:     1025 bytes
```

创建出来的`pod`都会将此`secret`挂载进去

```shell

[root@ops-pre-4-175 pod]# kubectl  describe pod cloud-act2-doc-6ddf66d4f6-fc5v4 -n idcos
Name:         cloud-act2-doc-6ddf66d4f6-fc5v4
Namespace:    idcos
Priority:     0
Node:         ops-pre-4-144/10.0.4.144
Start Time:   Mon, 07 Dec 2020 21:58:36 +0800
Labels:       app=cloud-act2-doc
              pod-template-hash=6ddf66d4f6
Annotations:  cni.projectcalico.org/podIP: 10.233.105.57/32
              cni.projectcalico.org/podIPs: 10.233.105.57/32
Status:       Running
IP:           10.233.105.57
IPs:
  IP:           10.233.105.57
Controlled By:  ReplicaSet/cloud-act2-doc-6ddf66d4f6
Containers:
  cloud-act2-doc:
    Container ID:   docker://0d30fff8dfbcf54287dd55a79fd4d3622c3a952698972a55e01dbfe1f959e53c
    Image:          registry.idcos.com/cloudpower/cloud-act2-docs:v1.0
	......
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-5tjh4 (ro)
  PodScheduled      True
Volumes:
  default-token-5tjh4:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-5tjh4
    Optional:    false
......
```

进入pod内部后即可查看到对应的文件

```shell
root@cloud-act2-doc-6ddf66d4f6-fc5v4:~# ls -l  /var/run/secrets/kubernetes.io/serviceaccount
total 0
lrwxrwxrwx 1 root root 13 Dec  7 13:58 ca.crt -> ..data/ca.crt
lrwxrwxrwx 1 root root 16 Dec  7 13:58 namespace -> ..data/namespace
lrwxrwxrwx 1 root root 12 Dec  7 13:58 token -> ..data/token
```

