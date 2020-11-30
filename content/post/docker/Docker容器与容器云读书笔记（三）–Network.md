---

date :  "2020-05-29T09:13:38+08:00" 
title : "Docker容器与容器云读书笔记（三）–Network" 
categories : ["技术文章"] 
tags : ["docker"] 
toc : true
---

### 网络基础

当启动`docker`的时候会默认创建一个`docker0`，这个便是和其他`docker`进行网络传输的网桥；

```
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        ether 02:42:59:bf:40:e7  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.103  netmask 255.255.0.0  broadcast 10.0.255.255
        inet6 fe80::250:56ff:fea0:8f1a  prefixlen 64  scopeid 0x20<link>
        ether 00:50:56:a0:8f:1a  txqueuelen 1000  (Ethernet)
        RX packets 200887258  bytes 19573562194 (18.2 GiB)
        RX errors 0  dropped 30161  overruns 0  frame 0
        TX packets 14665191  bytes 3565817089 (3.3 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 64886  bytes 26146714 (24.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 64886  bytes 26146714 (24.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

你可以控制网卡的开启或关闭
```shell
[root@CloudBoot-dev-2-103 ~]# ifconfig docker0 down
[root@CloudBoot-dev-2-103 ~]# ifconfig docker0 up
```

默认的，`docker`自己也会自动创建三种网络，分别是`bridge`、`host`、`none`

```shell
[root@CloudBoot-dev-2-103 ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
46b1a42ccb82        bridge              bridge              local
6017ecfecfee        host                host                local
5513d08af947        none                null                local
```

 [libnetwork](https://github.com/moby/libnetwork/blob/master/docs/design.md)里面内置了`bridge driver`、`host driver`、`null driver`、`remote driver`、`overlay driver`；其中`overlay`的模式使用了vxlan的方式；

这些网络都是由驱动创建出来的；在`docker`里面有好多的`driver`；你也可以自己写一个`driver`，只要实现[driverapi](https://github.com/moby/libnetwork/blob/master/driverapi/driverapi.go)里面的方法即可，这就组成了`docker`的网络插件；

### Bridge原理

创建两个`netns`

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns add ns1
[root@CloudBoot-dev-2-103 ~]# ip netns add ns2
```

创建一个网桥

```shell
[root@CloudBoot-dev-2-103 ~]# ip link add br0 type bridge
[root@CloudBoot-dev-2-103 ~]# ip link set br0 up
```

创建两对pair

```shell
[root@CloudBoot-dev-2-103 ~]# ip link add veth0 type veth peer name br-veth0
[root@CloudBoot-dev-2-103 ~]# ip link add veth1 type veth peer name br-veth1
```

将`veth0`放在`ns1`当中，`veth1`放在`ns`当中

```shell
[root@CloudBoot-dev-2-103 ~]# ip link set veth0 netns ns1
[root@CloudBoot-dev-2-103 ~]# ip link set veth1 netns ns2
```

将`br-veth0`和`br-veth1`分别设置在`br0`的网桥上面

```shell
[root@CloudBoot-dev-2-103 ~]# ip link set br-veth0 master br0
[root@CloudBoot-dev-2-103 ~]# ip link set br-veth1 master br0
[root@CloudBoot-dev-2-103 ~]# ip link set br-veth0 up
[root@CloudBoot-dev-2-103 ~]# ip link set br-veth1 up
```

设置IP地址到`veth0`和`veth1`上面

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth0
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth1
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns1 ip link set veth0 up
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns2 ip link set veth1 up
```

测试

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns1 ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=0.092 ms
^C
--- 10.0.0.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.092/0.092/0.092/0.000 ms
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns2 ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.063 ms
```

两个Bridge的实现

```shell
[root@CloudBoot-dev-2-103 ~]# ip link add br0 type bridge
[root@CloudBoot-dev-2-103 ~]# ip link add br1 type bridge
[root@CloudBoot-dev-2-103 ~]# ip link add br1 type bridge^C
[root@CloudBoot-dev-2-103 ~]# ip link add br0-veth0 type veth peer name br1-veth0
[root@CloudBoot-dev-2-103 ~]# ip link add br0-veth1 type veth peer name br1-veth1
[root@CloudBoot-dev-2-103 ~]# ip link set br0-veth0 master br0
[root@CloudBoot-dev-2-103 ~]# ip link set br0-veth1 master br0
[root@CloudBoot-dev-2-103 ~]# ip link set br1-veth0 master br1
[root@CloudBoot-dev-2-103 ~]# ip link set br1-veth1 master br1
[root@CloudBoot-dev-2-103 ~]# ip addr add 10.0.0.1/24 dev br0-veth0
[root@CloudBoot-dev-2-103 ~]# ip addr add 10.0.0.1/24 dev br1-veth0
[root@CloudBoot-dev-2-103 ~]# ip addr add 10.0.0.2/24 dev br0-veth1
[root@CloudBoot-dev-2-103 ~]# ip addr add 10.0.0.2/24 dev br1-veth1
[root@CloudBoot-dev-2-103 ~]# ip link set br0-veth0 up
[root@CloudBoot-dev-2-103 ~]# ip link set br0-veth1 up
[root@CloudBoot-dev-2-103 ~]# ip link set br1-veth0 up
[root@CloudBoot-dev-2-103 ~]# ip link set br1-veth1 up
```



### Docker里面的Bridge

#### 使用`docker0`

起一个容器

```shell
[root@CloudBoot-dev-2-103 ~]# docker run -it --name container1  busybox
```

启动完成后，宿主机会多出来一个`veth`虚拟网卡

```shell
veth34fcc8f: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::34d0:4fff:fed0:fc04  prefixlen 64  scopeid 0x20<link>
        ether 36:d0:4f:d0:fc:04  txqueuelen 0  (Ethernet)
        RX packets 8  bytes 656 (656.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 16  bytes 1312 (1.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

看看现在的网桥链路是怎么样的？

```shell
[root@CloudBoot-dev-2-103 ~]# brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.024259bf40e7       no              veth34fcc8f
```

容器里面的`etho0` ---> `veth34fcc8f` ---> `docker0` ----> `etho`

也就是说，启动容器的时候，默认使用的网桥即为`docker0`，由于`docker0`是内置的，所以无法显式使用

```shell
[root@CloudBoot-dev-2-103 ~]# docker run -it --name container1 --net docker0 busybox
/usr/bin/docker-current: Error response from daemon: network docker0 not found.
```

#### 使用`network bridge`

如果自己创建的网桥是怎么样的呢？

```shell
[root@CloudBoot-dev-2-103 ~]# docker network create backend
8ef64d30040c3f06938617bb08f8fed38e5d65ea3379ec46bc835e25eb3b9aa5
[root@CloudBoot-dev-2-103 ~]# docker network create frontend
ac1f8effbeefd604ba2d4b91c1d10a3b0cea24e338ce72dedc99904e4b627891
[root@CloudBoot-dev-2-103 ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
8ef64d30040c        backend             bridge              local
46b1a42ccb82        bridge              bridge              local
ac1f8effbeef        frontend            bridge              local
6017ecfecfee        host                host                local
5513d08af947        none                null                local
[root@CloudBoot-dev-2-103 ~]# ifconfig
br-8ef64d30040c: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        ether 02:42:d7:03:f6:05  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

br-ac1f8effbeef: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.19.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        ether 02:42:4d:5b:df:64  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

创建完`backend`、`frontend`后可以发现又多了两块网卡

我们起动一个容器

```shell
docker run -it --name container1 --net backend busybox
```

这个时候我们发现宿主机又多了一块网卡，它的ipv6地址与`backend`网络的`ipv6`在一个段内；

```shell
veth0edae48: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::587a:3fff:fe0b:df19  prefixlen 64  scopeid 0x20<link>
        ether 5a:7a:3f:0b:df:19  txqueuelen 0  (Ethernet)
        RX packets 11  bytes 894 (894.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9  bytes 698 (698.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

而容器里面的只有`eth0`，但是在上面添加了`172.18`和`fe80:42:`的网段

```shell
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:12:00:02
          inet addr:172.18.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe12:2/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:698 (698.0 B)  TX bytes:894 (894.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

看一下现在的网桥链路

```shell
[root@CloudBoot-dev-2-103 ~]# brctl show
bridge name             bridge id               STP enabled     interfaces
br-8ef64d30040c         8000.0242d703f605       no              veth0edae48
br-ac1f8effbeef         8000.02424d5bdf64       no
docker0                 8000.024259bf40e7       no
```

通讯方式是怎么样的呢？容器里面的`eth0` ---> `veth0edae48` ---> `br-8ef64d300f0c` ----> `eth0`；使用自己定义的网络还是使用默认的风格都是一样的原理；容器外面需要有`veth`与里面的`eth0`进行通讯，外面需要有指定的网桥与宿主机的`eth0`进行通讯；

