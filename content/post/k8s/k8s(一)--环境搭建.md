---
date :  "2020-01-28T13:36:27+08:00" 
title : "k8s(一)–环境搭建" 
categories : ["技术文章"] 
tags : ["k8s"] 
toc : true
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

```
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

```
systemctl restart network
```

设置主机名

```
hostnamectl set-hostname k8s-master
```

设置域名，配置/ect/hosts

```
 cat >> /etc/hosts << EOF
192.168.128.220    k8s-master
192.168.128.221    k8s-node01
192.168.128.222    k8s-node02
EOF
```

关闭防火墙

```
systemctl status firewalld &  systemctl stop firewalld & systemctl status firewalld 
systemctl status iptables &  systemctl stop iptables & systemctl status iptables
```

关闭selinux

```
setenforce 0

getenforce
vi /etc/selinux/config
```

关闭swap

```
vi /etc/fstab
## 注释
# /dev/mapper/centos-swap swap                    swap    defaults        0 0
```

开启透明网桥

```
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.d/k8s.conf
sysctl -p
```

开启ipvs

```
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
```

```
#执行脚本
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

### 安装docker-ce

```
yum remove docker-client docker-common docker -y
```

```
# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
```

配置cgroup

```
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

设置FORWARD ACCEPT

```
vi /usr/lib/systemd/system/docker.service
ExecStartPost=/usr/sbin/iptables -P FORWARD ACCEPT
```

重置并设置开机启动

```
 systemctl daemon-reload && systemctl restart docker.service && systemctl enable docker.service
```

### 安装k8s

```
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

```
systemctl enable kubelet && systemctl start kubelet
```

通过aliyun仓库拉取gc.src.io的镜像的一个脚本

```
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
```
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

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

查看状态

```
[root@k8s-master ~]# kubectl get nodes
NAME         STATUS     ROLES    AGE   VERSION
k8s-master   NotReady   master   36m   v1.17.2
```

状态未成功的原因未安装网络插件

```
kubectl describe node k8s-master | grep Ready
  Ready            False   Mon, 03 Feb 2020 12:48:44 +0800   Mon, 03 Feb 2020 12:08:03 +0800   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```

安装flannel

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

离线安装

```
curl -O https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel-aliyun.yml
kubectl apply -f kube-flannel-aliyun.yml
```

查看状态

```
[root@k8s-master ~]# kubectl get nodes
NAME         STATUS   ROLES    AGE   VERSION
k8s-master   Ready    master   78m   v1.17.2
```

#### 添加Node

```
kubeadm join 192.168.128.220:6443 --token j6crlr.k2eh15nkxw4ear9y --discovery-token-ca-cert-hash sha256:b79e738df3cafd3d303707f877242cfb634429566c84e78818e86798be85f705
```

```
[root@k8s-node1 ~]# kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   4h29m   v1.17.2
k8s-node1    Ready    <none>   2m10s   v1.17.2
k8s-node2    Ready    <none>   14m     v1.17.2
```

### 必看资源

- [reference](https://kubernetes.io/docs/reference/)： 命令行工具参数，像kubectl、kubeadm等，还有一些API列表
- [api-reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.17/#container-v1-core):用于查找一些配置参数信息

