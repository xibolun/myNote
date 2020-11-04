---
date :  "2020-03-05T21:43:03+08:00" 
title : "k8s--API" 
categories : ["技术文章"] 
tags : ["k8s"] 
toc : true
---

今天想使用`postman`使用一下`k8s`的API，看看`k8s`的API机制是怎么样的；

### API启动

查看`pod`列表你会发现有一个`api-server`，这个是`pod`就是管理`k8s api`的

```
[root@ops-pre-4-175 kubernetes]# kubectl get pods -n kube-system | grep api
kube-apiserver-ops-pre-4-175                   1/1     Running   0          20h
```

那是怎么启动的呢？看一下进程一目了然；

```shell
[root@ops-pre-4-175 kubernetes]# ps -axu | grep kube-apiserver
root     30672  4.5  3.6 843380 601720 ?       Ssl  Oct27  58:51 kube-apiserver ......
```

```shell
kube-apiserver
    --advertise-address=10.0.4.175
    --allow-privileged=true
    --anonymous-auth=True
    --apiserver-count=1
    --authorization-mode=Node,RBAC
    --bind-address=0.0.0.0
    --client-ca-file=/etc/kubernetes/pki/ca.crt
    --enable-admission-plugins=NodeRestriction
    --enable-aggregator-routing=False
    --enable-bootstrap-token-auth=true
    --endpoint-reconciler-type=lease
    --enable-swagger-ui=true
    ## etcd认证文件
    --etcd-cafile=/etc/ssl/etcd/ssl/ca.pem
    --etcd-certfile=/etc/ssl/etcd/ssl/node-Ops-pre-4-175.pem
    --etcd-keyfile=/etc/ssl/etcd/ssl/node-Ops-pre-4-175-key.pem
    --etcd-servers=https://10.0.4.175:2379
    --feature-gates=CSINodeInfo=true,VolumeSnapshotDataSource=true,ExpandCSIVolumes=true,RotateKubeletClientCertificate=true
    --insecure-port=0
    ## client调用的认证文件
    --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    --profiling=False
    --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    --requestheader-allowed-names=front-proxy-client
    --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    --requestheader-extra-headers-prefix=X-Remote-Extra-
    --requestheader-group-headers=X-Remote-Group
    --requestheader-username-headers=X-Remote-User
    --secure-port=6443
    --service-account-key-file=/etc/kubernetes/pki/sa.pub
    --service-cluster-ip-range=10.233.0.0/18
    --storage-backend=etcd3
    ## tls认证文件
    --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
```

镜像里面有一个`kube-apiserver`的工具，有一大堆的参数，[这些参数有一个详细的列表](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)

#### 认证方式

- 证书认证：从上面的`kube-apiserver`启动参数里面可以看出，是以`crt`的方式来处理，
- `Token认证`：也可以指定`--token-auth-file=xxxx`进行使用`token`的方式认证
- [ServiceAccountTokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#service-account-tokens)
- [BootstrapTokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#bootstrap-tokens)
- [openid插件](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens)
- [通过配置Header里面的用户进行认证](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authenticating-proxy)
- [无认证请求](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests)

### Postman使用

由于是`6443`端口，需要使用证书和`key`；

```
[root@ops-pre-4-175 kubernetes]# ll /etc/kubernetes/pki | grep apiserver-kubelet
-rw-r--r-- 1 kube root 1099 Sep 16 16:42 apiserver-kubelet-client.crt
-rw------- 1 kube root 1679 Sep 16 16:42 apiserver-kubelet-client.key
```

> pki下面的文件列表还有很多，选择这两个原因是因为， apiserver在启动的时候指定了client的认证方式
>
> ​	--kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
> ​    --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key

将上面的这两个文件下载至本地，然后配置至`postman`的`Certificates`里面

- host: https://{masterIP}:6443
- CRT file: apiserver-kubelet-client.crt
- Key file:apiserver-kubelet-client.key

请求接口即可

```
https://10.0.4.175:6443/apis 
```

### GoClient使用

详情见 [client-go](https://github.com/kubernetes/client-go)

### API代理

```shell
kubectl proxy --address="0.0.0.0" -p 8080 --accept-hosts='^*$' &
```

即可使用`http://10.0.4.175:8080/apis`请求api，不需要token认证，因为内部已经做了认证处理；

### 集成swagger

当启动`apiserver`的时候，添加了

```shell
--enable-swagger-ui=true
```

1.18版本之后废弃了`swagger`的支持，现在怎么办呢？虽然废弃了`swagger`，但是支持了`openapi`

```shell
curl -L http://10.0.4.175:8080/openapi/v2 -o /tmp/swagger.json
docker run -p 80:8080 -e BASE_URL=/swagger -e SWAGGER_JSON=/foo/swagger.json -v /tmp:/foo swaggerapi/swagger-ui
```

再使用`swagger-ui`镜像生成即可

```yaml
version: '3'
services:
  swagger:
    image: swaggerapi/swagger-ui
    ports:
      - 80:8080
    volumes:
      - {swagger_json dir}:/foo
    environment:
      SWAGGER_JSON: "/foo/swagger.json"
```

请求`http://localhost/swagger`即可;

### API列表

[API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#-strong-api-overview-strong-)分为几类

- `workloads`：工作负载相关；`deployment`、`pod`、`node`等
- `service` ：服务相关的接口
- `config&storage`：配置、存储之类的接口
- `metadata api`： metadata配置信息
- `cluster api`：集群配置信息

