---

date :  "2020-06-03T09:37:06+08:00" 
title : "Docker守护进程" 
categories : ["docker"] 
tags : ["docker"] 
toc : true
---

## Docker进程

> 当前Docker版本
>
> ```shell
> Client:
>  Version:         1.13.1
>  API version:     1.26
>  Package version: docker-1.13.1-203.git0be3e21.el7.centos.x86_64
>  Go version:      go1.10.3
>  Git commit:      0be3e21/1.13.1
>  Built:           Thu Nov 12 15:11:46 2020
>  OS/Arch:         linux/amd64
> 
> Server:
>  Version:         1.13.1
>  API version:     1.26 (minimum version 1.12)
>  Package version: docker-1.13.1-203.git0be3e21.el7.centos.x86_64
>  Go version:      go1.10.3
>  Git commit:      0be3e21/1.13.1
>  Built:           Thu Nov 12 15:11:46 2020
>  OS/Arch:         linux/amd64
>  Experimental:    false
> ```

### Docker启动后的情形

以`grafana`为例先看一下现在的实例情况

```shell
[root@CloudBoot-dev-2-103 ~]# docker ps | grep 17d0801f3a10
17d0801f3a10        grafana/grafana                                   "/run.sh"                10 days ago         Up 10 days          0.0.0.0:20002->3000/tcp   grafana

## 17d0801f3a10容器的进程为625，父进程为15935
[root@CloudBoot-dev-2-103 ~]# ps -ef | grep 17d
root       625 15935  0 Dec03 ?        00:00:00 /usr/bin/docker-containerd-shim-current 17d0801f3a105d7226ca2ec029a7957a764c40ad68d4e91b0d34c5ebc1debf67 /var/run/docker/libcontainerd/17d0801f3a105d7226ca2ec029a7957a764c40ad68d4e91b0d34c5ebc1debf67 /usr/libexec/docker/docker-runc-current

## pstree看一下进程635下的线程列表
[root@CloudBoot-dev-2-103 ~]# pstree 625 -p
[root@CloudBoot-dev-2-103 ~]# pstree 625
docker-containe─┬─grafana-server───10*[{grafana-server}]
                └─9*[{docker-containe}]
       
## pstree可以看到父进程下面都是和635一样的信息，都是一个一个地docker-containe
[root@CloudBoot-dev-2-103 ~]# pstree 15935
docker-containe─┬─docker-containe─┬─grafana-server───10*[{grafana-server}]
                │                 └─9*[{docker-containe}]
                ├─docker-containe─┬─cadvisor───13*[{cadvisor}]
                │                 └─9*[{docker-containe}]
                ├─docker-containe─┬─node_exporter───8*[{node_exporter}]
                │                 └─9*[{docker-containe}]
                ├─docker-containe─┬─sh───java───18*[{java}]
                │                 └─9*[{docker-containe}]
                ├─docker-containe─┬─prometheus───7*[{prometheus}]
                │                 └─9*[{docker-containe}]
                ├─docker-containe─┬─e3w───7*[{e3w}]
                │                 └─9*[{docker-containe}]
                └─16*[{docker-containe}]       
## 15935整体的情况如下图，可以看到其父进程为15929
[root@CloudBoot-dev-2-103 ~]# ps -axjf | grep 15935
[root@CloudBoot-dev-2-103 ~]# ps -axjf | grep 15935
15929 15935 15935 \_ /usr/bin/docker-containerd-current -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc --runtime-args --systemd-cgroup=true
15935   625   625 |   \_ /usr/bin/docker-containerd-shim-current 17d0801f3a105d7226ca2ec029a7957a764c40ad68d4e91b0d34c5ebc1debf67 /var/run/docker/libcontainerd/17d0801f3a105d7226ca2ec029a7957a764c40ad68d4e91b0d34c5ebc1debf67 /usr/libexec/docker/docker-runc-current
15935   694   694 |   \_ /usr/bin/docker-containerd-shim-current 9f0482925ecb9b7a7f2518becae1dd25abd13890c5e86b49a6e719845b54ad3f /var/run/docker/libcontainerd/9f0482925ecb9b7a7f2518becae1dd25abd13890c5e86b49a6e719845b54ad3f /usr/libexec/docker/docker-runc-current
15935   759   759 |   \_ /usr/bin/docker-containerd-shim-current f8be4aea02c52a21b56e4f819f69b65da80aaac0194e0165e09ecc9641090f37 /var/run/docker/libcontainerd/f8be4aea02c52a21b56e4f819f69b65da80aaac0194e0165e09ecc9641090f37 /usr/libexec/docker/docker-runc-current
15935   782   782 |   \_ /usr/bin/docker-containerd-shim-current 2d4396a783ec700de4a66e78ad9b705bd588f9a111e52719564c5685a9b5ec0b /var/run/docker/libcontainerd/2d4396a783ec700de4a66e78ad9b705bd588f9a111e52719564c5685a9b5ec0b /usr/libexec/docker/docker-runc-current
15935  2928  2928 |   \_ /usr/bin/docker-containerd-shim-current 9258cc59fd401f1b7f2e41ff3b0704203706472a4be13a3c2d238ada606fdc10 /var/run/docker/libcontainerd/9258cc59fd401f1b7f2e41ff3b0704203706472a4be13a3c2d238ada606fdc10 /usr/libexec/docker/docker-runc-current
15935 28961 28961 |   \_ /usr/bin/docker-containerd-shim-current 850ba3fda533a140310a6f4864af0d019f47f4631e512a1edccd405c66bac102 /var/run/docker/libcontainerd/850ba3fda533a140310a6f4864af0d019f47f4631e512a1edccd405c66bac102 /usr/libexec/docker/docker-runc-current
```

使用`docker-containerd-current`命令启动一个守护进程，连接`docker-containerd.sock`文件，以`docker-runc`为`runtime`启动，下面挂着许多的`docker-containered-shim-current`子进程

而父节点`15929`是什么情况呢？

```shell
## 进程15929的信息如下，其父节点为1，启动进程
[root@CloudBoot-dev-2-103 ~]# ps -axjf | grep 15929
    1 15929 15929 /usr/bin/dockerd-current --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current --default-runtime=docker-runc --exec-opt native.cgroupdriver=systemd --userland-proxy-path=/usr/libexec/docker/docker-proxy-current --init-path=/usr/libexec/docker/docker-init-current --seccomp-profile=/etc/docker/seccomp.json --selinux-enabled --log-driver=journald --signature-verification=false --storage-driver overlay2
15929 15935 15935  \_ /usr/bin/docker-containerd-current -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc --runtime-args --systemd-cgroup=true
15929   598 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 20002 -container-ip 172.18.0.2 -container-port 3000
15929   674 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 8080 -container-ip 172.18.0.4 -container-port 8080
15929   717 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 38080 -container-ip 172.18.0.5 -container-port 8088
15929   748 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 9100 -container-ip 172.18.0.6 -container-port 9100
15929  2921 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 9090 -container-ip 172.18.0.3 -container-port 9090
15929 28955 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 1080 -container-ip 172.19.0.2 -container-port 8080
```

使用`dockerd-current`命令，启动一个进程，下面挂着`docker-containerd-current`，`docker-proxy-curren`子进程；

整体的图如下：

```shell
    1 15929 15929 /usr/bin/dockerd-current --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current --default-runtime=docker-runc --exec-opt native.cgroupdriver=systemd --userland-proxy-pa
15929 15935 15935  \_ /usr/bin/docker-containerd-current -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontai
15935   625   625  |   \_ /usr/bin/docker-containerd-shim-current 17d0801f3a105d7226ca2ec029a7957a764c40ad68d4e91b0d34c5ebc1debf67 /var/run/docker/libcontainerd/17d0801f3a105d7226ca2ec029a7957a764c
  625   672   672  |   |   \_ grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini --packaging=docker cfg:default.log.mode=console cfg:default.paths.data=/var/lib/grafana
15935   694   694  |   \_ /usr/bin/docker-containerd-shim-current 9f0482925ecb9b7a7f2518becae1dd25abd13890c5e86b49a6e719845b54ad3f /var/run/docker/libcontainerd/9f0482925ecb9b7a7f2518becae1dd25abd1
  694   749   749  |   |   \_ /usr/bin/cadvisor -logtostderr
15935   759   759  |   \_ /usr/bin/docker-containerd-shim-current f8be4aea02c52a21b56e4f819f69b65da80aaac0194e0165e09ecc9641090f37 /var/run/docker/libcontainerd/f8be4aea02c52a21b56e4f819f69b65da80a
  759   777   777  |   \_ /bin/node_exporter --path.procfs=/host/proc --path.rootfs=/rootfs --path.sysfs=/host/sys --collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)
15935   782   782  |   \_ /usr/bin/docker-containerd-shim-current 2d4396a783ec700de4a66e78ad9b705bd588f9a111e52719564c5685a9b5ec0b /var/run/docker/libcontainerd/2d4396a783ec700de4a66e78ad9b705bd588
  782   802   802  |   |   \_ /bin/sh -c java -javaagent:/data/jmx_prometheus_javaagent-0.14.0.jar=8088:/data/proemtheus-jmx-config.yaml -jar /data/arthas-demo.jar
  802  1010   802  |   |       \_ java -javaagent:/data/jmx_prometheus_javaagent-0.14.0.jar=8088:/data/proemtheus-jmx-config.yaml -jar /data/arthas-demo.jar
15935  2928  2928  |   \_ /usr/bin/docker-containerd-shim-current 9258cc59fd401f1b7f2e41ff3b0704203706472a4be13a3c2d238ada606fdc10 /var/run/docker/libcontainerd/9258cc59fd401f1b7f2e41ff3b0704203706
 2928  2945  2945  |   |   \_ /bin/prometheus --config.file=/prometheus/prometheus.yml --web.enable-lifecycle --web.enable-admin-api --storage.tsdb.retention=1y
15935 28961 28961  |   \_ /usr/bin/docker-containerd-shim-current 850ba3fda533a140310a6f4864af0d019f47f4631e512a1edccd405c66bac102 /var/run/docker/libcontainerd/850ba3fda533a140310a6f4864af0d019f47
28961 28978 28978  |       \_ ./e3w
15929   598 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 20002 -container-ip 172.18.0.2 -container-port 3000
15929   674 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 8080 -container-ip 172.18.0.4 -container-port 8080
15929   717 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 38080 -container-ip 172.18.0.5 -container-port 8088
15929   748 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 9100 -container-ip 172.18.0.6 -container-port 9100
15929  2921 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 9090 -container-ip 172.18.0.3 -container-port 9090
15929 28955 15929  \_ /usr/libexec/docker/docker-proxy-current -proto tcp -host-ip 0.0.0.0 -host-port 1080 -container-ip 172.19.0.2 -container-port 8080
```

![docker进程](/img/docker/docker-process.jpg)

可以看到整体的关系如上图所示：

- `dockerd`启动了一个进程，即`docker daemon`或者说`docker engine`，所有的`api`服务都是由此项提供
- 通过`dockerd`又启动了`docker-containerd`
- 当每启动一个`docker instance`的时候，就会启动一个`docker-containerd-shim`和`docker-proxy`
  - `docker-containerd-shim`是`docker instance`的守护进程
  - `docker-proxy`为`docker instance`提供`iptables`的端口映射关系

那为什么需要中间再包一层`docker-containerd-shim`呢？

`shim`意思为`垫片`，标准的`OCI(open container initiative)`组织制定了容器标准，`shim`是做为一层封装来实现，默认的实现即为`runc`；

我们启动一个容器的命令可以转换为`shim`命令

```shell
## run命令
docker run -d

## shim命令
/usr/bin/docker-containerd-shim-current f8be4aea02c52a21b56e4f819f69b65da80aaac0194e0165e09ecc9641090f37 /var/run/docker/libcontainerd/f8be4aea02c52a21b56e4f819f69b65da80aaac0194e0165e09ecc9641090f37 /usr/libexec/docker/docker-runc-current
```

区别在于`shim`命令所需要一系列的参数信息即`runc`所需要运行的配置文件和标准的输入/输出

```shell
[root@CloudBoot-dev-2-103 ~]# ll /var/run/docker/libcontainerd/f8be4aea02c52a21b56e4f819f69b65da80aaac0194e0165e09ecc9641090f37
total 24
-rw-r--r-- 1 root root 20733 Dec  3 09:49 config.json
prwx------ 1 root root     0 Dec 14 10:27 init-stderr
prwx------ 1 root root     0 Dec  3 09:49 init-stdin
prwx------ 1 root root     0 Dec  3 09:49 init-stdout
```

