---

date :  "2020-02-16T10:53:23+08:00" 
title : "k8s(六)––Secret" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
---

### 基本了解

[secret](https://kubernetes.io/docs/concepts/configuration/secret/)是为了存储一些安全、敏感的数据信息，比如说认证信息，帐号、sshkey等；它有很多的类型 [secret-types](https://kubernetes.io/docs/concepts/configuration/secret/#secret-types)；

### docker认证

#### 配置

首先登陆`docker`的私有仓库

```shell
docker login registry.idcos.com
```

输入用户名和密码后会生成一个配置文件

```shell
[root@ops-pre-4-175 k8sConfigs]# ll /root/.docker/config.json
-rw------- 1 root root 161 Dec  1 10:44 /root/.docker/config.json
```

对此配置文件进行`base64`后配置至`secret`的资源文件当中

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: idcos-registry-key
data: 
  .dockercfg: {cat ~/.docker/config.json |base64 -w 0}
type: kubernets.io/dockercfgjson
```

其中`type`即为诸多[secret-types](https://kubernetes.io/docs/concepts/configuration/secret/#secret-types)当中的`dockercfgjson`；

创建并查看

```shell
[root@ops-pre-4-175 k8sConfigs]# kubectl create -f secret/image-pull-secret.yaml
[root@ops-pre-4-175 k8sConfigs]# kubectl get secret
NAME                  TYPE                                  DATA   AGE
idcos-registry-key    kubernets.io/dockercfg                1      8m14s
```

或者使用`curl`请求创建

```shell
curl -X POST \
  https://10.0.4.175:6443/api/v1/namespaces/idcos/secrets \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
    "apiVersion": "v1",
    "kind": "Secret",
    "metadata": {
        "name": "idcos-registry-key",
        "namespace": "idcos"
    },
    "data": {
        ".dockerconfigjson": "base64values"
    },
    "type": "kubernetes.io/dockerconfigjson"
}'
```

#### 使用

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cloud-act2-docs
  namespace: idcos
  labels:
    app: cloud-act2-docs
spec:
  containers:
    - name: cloud-act2-docs
      image: registry.idcos.com/cloudpower/cloud-act2-docs:v1.0
  restartPolicy: Always
  ## 使用imagePullSecrets
  imagePullSecrets:
    - name: idcos-registry-key
```

### 参考

- [tonybai的blog](https://tonybai.com/2016/11/16/how-to-pull-images-from-private-registry-on-kubernetes-cluster/)