---
date :  "2020-01-28T13:36:27+08:00" 
title : "k8s(一)––环境搭建" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
description : k8s 环境搭建
---

## K8S环境搭建

### 其他搭建方式

- 学习环境，可以安装 [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/#installation) ，同时还有一个在线的 [minikube terminal](https://kubernetes.io/docs/tutorials/hello-minikube/#create-a-minikube-cluster)，也可以使用[k8s kind](https://kind.sigs.k8s.io/) 来搭建环境
- 生产环境，使用 [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)，本次搭建使用kubeadm来搭建，更多 [kubeadm command](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/)。

### Centos7环境搭建

| IP              | 说明   |
| --------------- | ------ |
| 192.168.128.220 | master |
| 192.168.128.221 | node1  |
| 192.168.128.222 | node2  |

> 配置要求：>2C4G50G

### 操作系统设置

设置静态IP

```shell
vi /etc/sysconfig/network-scripts/ifcfg-ens33

....
BOOTPROTO="static"
ONBOOT="yes"
.....
IPADDR=192.168.128.220
NETMASK=255.255.255.0
GATEWAY=192.168.128.2
```

重启

```shell
systemctl restart network
```

设置主机名

```shell
hostnamectl set-hostname k8s-master
```

设置域名，配置/ect/hosts

```shell
 cat >> /etc/hosts << EOF
192.168.128.220    k8s-master
192.168.128.221    k8s-node01
192.168.128.222    k8s-node02
EOF
```

关闭防火墙

```shell
systemctl status firewalld &  systemctl stop firewalld & systemctl status firewalld 
systemctl status iptables &  systemctl stop iptables & systemctl status iptables
```

关闭selinux

```shell
setenforce 0

getenforce
vi /etc/selinux/config
```

关闭swap

```shell
vi /etc/fstab
## 注释
# /dev/mapper/centos-swap swap                    swap    defaults        0 0
```

开启透明网桥

```shell
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.d/k8s.conf
sysctl -p
```

开启ipvs

```shell
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
```

```shell
#执行脚本
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

### 安装docker-ce

```
yum remove docker-client docker-common docker -y
```

```shell
# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
```

配置cgroup

```shell
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

设置FORWARD ACCEPT

```shell
vi /usr/lib/systemd/system/docker.service
ExecStartPost=/usr/sbin/iptables -P FORWARD ACCEPT
```

重置并设置开机启动

```shell
 systemctl daemon-reload && systemctl restart docker.service && systemctl enable docker.service
```

### 安装k8s

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl
```

启动

```shell
systemctl enable kubelet && systemctl start kubelet
```

通过aliyun仓库拉取gc.src.io的镜像的一个脚本

```shell
vi /tmp/image.sh
#!/bin/bash
url=registry.cn-hangzhou.aliyuncs.com/google_containers
version=v1.17.2
images=(`kubeadm config images list --kubernetes-version=$version|awk -F '/' '{print $2}'`)
for imagename in ${images[@]} ; do
  docker pull $url/$imagename
  docker tag $url/$imagename k8s.gcr.io/$imagename
  docker rmi -f $url/$imagename
done

sh /tmp/image.sh
docker image
```

> version获取：kubelet --version

#### 初始化master

```shell
kubeadm init --image-repository registry.aliyuncs.com/google_containers  --kubernetes-version v1.17.0 --pod-network-cidr=10.244.0.0/16  --apiserver-advertise-address=192.168.128.220 
```

输出信息
```shell
kubeadm init --image-repository registry.aliyuncs.com/google_containers  --kubernetes-version v1.17.0 --pod-network-cidr=10.244.0.0/16  --apiserver-advertise-address=192.168.128.220 
W0203 12:06:56.185377    4249 validation.go:28] Cannot validate kube-proxy config - no validator is available
W0203 12:06:56.185442    4249 validation.go:28] Cannot validate kubelet config - no validator is available
[init] Using Kubernetes version: v1.17.0
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.128.220]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.128.220 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.128.220 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0203 12:07:53.278042    4249 manifests.go:214] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0203 12:07:53.279114    4249 manifests.go:214] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 20.032332 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.17" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: j6crlr.k2eh15nkxw4ear9y
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.128.220:6443 --token j6crlr.k2eh15nkxw4ear9y \
    --discovery-token-ca-cert-hash sha256:b79e738df3cafd3d303707f877242cfb634429566c84e78818e86798be85f705
```

设置`kubectl`命令行环境

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

查看状态

```shell
[root@k8s-master ~]# kubectl get nodes
NAME         STATUS     ROLES    AGE   VERSION
k8s-master   NotReady   master   36m   v1.17.2
```

状态未成功的原因未安装网络插件

```shell
kubectl describe node k8s-master | grep Ready
  Ready            False   Mon, 03 Feb 2020 12:48:44 +0800   Mon, 03 Feb 2020 12:08:03 +0800   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```

安装flannel

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

离线安装

```shell
curl -O https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel-aliyun.yml
kubectl apply -f kube-flannel-aliyun.yml
```

查看状态

```shell
[root@k8s-master ~]# kubectl get nodes
NAME         STATUS   ROLES    AGE   VERSION
k8s-master   Ready    master   78m   v1.17.2
```

#### 添加Node

```shell
kubeadm join 192.168.128.220:6443 --token j6crlr.k2eh15nkxw4ear9y --discovery-token-ca-cert-hash sha256:b79e738df3cafd3d303707f877242cfb634429566c84e78818e86798be85f705
```

```shell
[root@k8s-node1 ~]# kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   4h29m   v1.17.2
k8s-node1    Ready    <none>   2m10s   v1.17.2
k8s-node2    Ready    <none>   14m     v1.17.2
```

### 卸载

- 重置

```shell
kubeadm reset
```

- 删除目录

```shell
rm -rf /etc/cni/
rm -rf /var/lib/etcd/
rm -rf /var/lib/kubelet/
rm -rf /var/lib/dockershim/
rm -rf /var/lib/cni
```

- 清空iptables规则

```shell
ipvsadm --clear
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

- 删除 `ip link`，只需要保留`lo,eth0,docker0`

```shell
ip link delete cni0
ip link delete flannel.1
ip link delete kube-ipvs0
```

### WebUI

```shell
kubectl proxy --address='0.0.0.0' --port=8001 --accept-hosts='.*'
```

[Token生成及登陆](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

### 必看资源

- [reference](https://kubernetes.io/docs/reference/)： 命令行工具参数，像kubectl、kubeadm等，还有一些API列表
- [api-reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.17/#container-v1-core):用于查找一些配置参数信息





## MacOS环境搭建(minikube)

### 下载Vm-Driver

macos上面可选的`driver`有许多种 [drivers/macos](https://minikube.sigs.k8s.io/docs/drivers/#macos)，选择一个下载即可；我选择的是`virtualbox`

### 安装[Minikube](https://minikube.sigs.k8s.io/docs/start/)

版本要求在1.7以上，否则在使用的时候会报如下错误：

```shell
➜  ~ minikube start --vm-driver=virtualbox  --image-repository=https://registry.docker-cn.com --memory=4g
😄  minikube v1.6.2 on Darwin 10.14
✨  Selecting 'virtualbox' driver from user configuration (alternates: [hyperkit])
⚠️  Not passing HTTP_PROXY=127.0.0.1:1087 to docker env.
⚠️  Not passing HTTPS_PROXY=127.0.0.1:1087 to docker env.
✅  Using image repository https://registry.docker-cn.com
🔥  Creating virtualbox VM (CPUs=2, Memory=4000MB, Disk=20000MB) ...
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x28 pc=0x4ecd70f]

goroutine 95 [running]:
github.com/google/go-containerregistry/pkg/v1/tarball.Write(0x0, 0xc00004c990, 0x6, 0xc00004c997, 0x1b, 0xc0002e40e3, 0x7, 0x0, 0x0, 0xc00053bc68, ...)
        /private/tmp/minikube-20191220-77113-wmp8w9/.brew_home/go/pkg/mod/github.com/google/go-containerregistry@v0.0.0-20180731221751-697ee0b3d46e/pkg/v1/tarball/write.go:57 +0x12f
k8s.io/minikube/pkg/minikube/machine.CacheImage(0xc0002e40c0, 0x2a, 0xc0002ee500, 0x4e, 0x0, 0x0)
        /private/tmp/minikube-20191220-77113-wmp8w9/pkg/minikube/machine/cache_images.go:395 +0x5df
k8s.io/minikube/pkg/minikube/machine.CacheImages.func1(0xc0003a5768, 0x0)
        /private/tmp/minikube-20191220-77113-wmp8w9/pkg/minikube/machine/cache_images.go:85 +0x124
golang.org/x/sync/errgroup.(*Group).Go.func1(0xc000498420, 0xc000498540)
        /private/tmp/minikube-20191220-77113-wmp8w9/.brew_home/go/pkg/mod/golang.org/x/sync@v0.0.0-20190423024810-112230192c58/errgroup/errgroup.go:57 +0x64
created by golang.org/x/sync/errgroup.(*Group).Go
        /private/tmp/minikube-20191220-77113-wmp8w9/.brew_home/go/pkg/mod/golang.org/x/sync@v0.0.0-20190423024810-112230192c58/errgroup/errgroup.go:54 +0x66
```

`minikube`的issues里面也有描述 [minikube/issues/6428](https://github.com/kubernetes/minikube/issues/6428)

#### brew安装

```shell
brew install minikube
```

#### 直接下载安装

```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

### 安装集群

```shell
minikube start --vm-driver=virtualbox
```

> 中间会拉取k8s的相关镜像，需要开启proxy代理

### 安装kubectl

```shell
brew install kubectl
```

### 测试

部署nginx

```shell
kubectl apply  -f  https://k8s.io/examples/application/deployment.yaml
```

> 部署前可以使用`kubectl get --watch deployment`观察deployment的状态

查看状态

```shell
➜  ~ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   0/2     2            0           4m30s
```

### 一些信息

查看集群

```shell
➜  ~ kubectl get po -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-nnm5b           1/1     Running   0          72m
kube-system   coredns-66bff467f8-wk9x5           1/1     Running   0          72m
kube-system   etcd-minikube                      1/1     Running   0          72m
kube-system   kube-apiserver-minikube            1/1     Running   0          72m
kube-system   kube-controller-manager-minikube   1/1     Running   0          72m
kube-system   kube-proxy-pxvlk                   1/1     Running   0          72m
kube-system   kube-scheduler-minikube            1/1     Running   0          72m
kube-system   storage-provisioner                1/1     Running   0          72m
```

查看`Dashboard`

```shell
➜  ~ minikube dashboard
🔌  Enabling dashboard ...
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:62758/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

查看服务

```shell
➜  ~ minikube addons list
|-----------------------------|----------|--------------|
|         ADDON NAME          | PROFILE  |    STATUS    |
|-----------------------------|----------|--------------|
| dashboard                   | minikube | enabled ✅   |
| default-storageclass        | minikube | enabled ✅   |
| efk                         | minikube | disabled     |
| freshpod                    | minikube | disabled     |
| gvisor                      | minikube | disabled     |
| helm-tiller                 | minikube | disabled     |
| ingress                     | minikube | disabled     |
| ingress-dns                 | minikube | disabled     |
| istio                       | minikube | disabled     |
| istio-provisioner           | minikube | disabled     |
| logviewer                   | minikube | disabled     |
| metrics-server              | minikube | disabled     |
| nvidia-driver-installer     | minikube | disabled     |
| nvidia-gpu-device-plugin    | minikube | disabled     |
| registry                    | minikube | disabled     |
| registry-aliases            | minikube | disabled     |
| registry-creds              | minikube | disabled     |
| storage-provisioner         | minikube | enabled ✅   |
| storage-provisioner-gluster | minikube | disabled     |
|-----------------------------|----------|--------------|
```



### 如何连接至Minikube VM

#### 方式一

```shell
➜  ~ minikube ssh
                         _             _
            _         _ ( )           ( )
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$
```

查看IP

```shell
➜  ~ minikube ip
192.168.99.102
```

由于`minikube`使用 [boot2docker](https://github.com/boot2docker/boot2docker#ssh-into-vm)，所以默认用户名密码为`docker/tcuser`

```shell
ssh docker@192.168.99.102
```

