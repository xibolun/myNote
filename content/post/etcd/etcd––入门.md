---

date :  "2020-07-01T14:17:18+08:00" 
title : "etcd––入门" 
categories : ["技术文章"] 
tags : ["etcd"] 
toc : true
---

### 环境搭建

现在有了`docker`，环境搭建就非常的简单了

```shell
/usr/bin/docker run --restart=on-failure:5 --env-file=/etc/etcd.env --net=host -v /etc/ssl/certs:/etc/ssl/certs:ro -v /etc/ssl/etcd/ssl:/etc/ssl/etcd/ssl:ro -v /var/lib/et
cd:/var/lib/etcd:rw --memory=512M --blkio-weight=1000 --name=etcd1 kubesphere/etcd:v3.3.12 /usr/local/bin/etcd
```

### 使用

#### 连接

```shell
export ETCDCTL_API=3
etcdctl --endpoints=10.0.4.175:2379,10.0.4.175:2380 --cacert=/etc/ssl/etcd/ssl/ca.pem  --cert=/etc/ssl/etcd/ssl/node-Ops-pre-4-175.pem --key=/etc/ssl/etcd/ssl/node-Ops-pre-4-175-key.pem member list
```

alias一下会比较方便

```shell
alias etcdctl='etcdctl --endpoints=10.0.4.175:2379,10.0.4.175:2380 --cacert=/etc/ssl/etcd/ssl/ca.pem  --cert=/etc/ssl/etcd/ssl/node-Ops-pre-4-175.pem --key=/etc/ssl/etcd/ssl/node-Ops-pre-4-175-key.pem'
```

#### CRUD

```
etcdctl put name pengganyu
etcdctl get name
etcdctl watch name
etcdctl delete name
etcdctl del name
```

其他还有一些高级的功能 [与etcd交互](https://etcd.io/docs/v3.4.0/dev-guide/interacting_v3/)

#### 租约(lease)

```shell
## 创建一个租约
[root@ops-pre-4-175 etcd]# etcdctl lease grant 1000
lease 1b9a74962253858c granted with TTL(1000s)
## 绑定key到租约上面
[root@ops-pre-4-175 etcd]# etcdctl put --lease=1b9a74962253858c name pengganyu
OK
## 查看租约的存活时间
[root@ops-pre-4-175 etcd]# etcdctl lease timetolive 1b9a74962253858c
lease 1b9a74962253858c granted with TTL(1000s), remaining(875s)
## 查看租约的存活时间，以及关联的keys
[root@ops-pre-4-175 etcd]# etcdctl lease timetolive --keys 1b9a74962253858c
lease 1b9a74962253858c granted with TTL(1000s), remaining(949s), attached keys([name])
## 撤销租约
[root@ops-pre-4-175 etcd]# etcdctl lease revoke 1b9a74962253858c
lease 1b9a74962253858c revoked
[root@ops-pre-4-175 etcd]# etcdctl lease timetolive 1b9a74962253858c
lease 1b9a74962253858c already expired
```

续约

```shell
## 维持一个租约
[root@ops-pre-4-175 etcd]# etcdctl lease grant 10
lease 1b9a749622539532 granted with TTL(10s)
[root@ops-pre-4-175 etcd]# etcdctl lease keep-alive 1b9a749622539532
## 另起一个终端，查看
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(8s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(6s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(9s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(8s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(7s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(6s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(9s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(8s)
[root@ops-pre-4-175 ~]# etcdctl lease timetolive 1b9a749622539532
lease 1b9a749622539532 granted with TTL(10s), remaining(8s)
```

可以看到续约并不是到了0，再进行续，而是根据命令来续约，`keep-alive`每执行一次续约的命令就会成功续约；

#### 成员管理



### Web-UI

使用`e3w`，它需要依赖一个配置文件`e2w.ini`，然后自己再写一个`docker-compose.yml`，由于需要证书，所以证书也需要挂载进去；整体目录结构如下：

```shell
# find etcd/
etcd/
etcd/node-Ops-pre-4-175-key.pem
etcd/node-Ops-pre-4-175.pem
etcd/ca.pem
etcd/e3w.yml
etcd/e3w.ini
```

```ini
[app]
port=8080
auth=false

[etcd]
root_key=e3w_test
dir_value=
addr=10.0.4.175:2379,10.0.4.175:2380
username=
password=
cert_file=/etc/ssl/etcd/ssl/node-Ops-pre-4-175.pem
key_file=/etc/ssl/etcd/ssl/node-Ops-pre-4-175-key.pem
ca_file=/etc/ssl/etcd/ssl/ca.pem
```

```yaml
version: '3'
services:
  e3w:
    image: soyking/e3w:latest
    volumes:
      - ./node-Ops-pre-4-175.pem:/etc/ssl/etcd/ssl/node-Ops-pre-4-175.pem
      - ./node-Ops-pre-4-175-key.pem:/etc/ssl/etcd/ssl/node-Ops-pre-4-175-key.pem
      - ./ca.pem:/etc/ssl/etcd/ssl/ca.pem
      - ./e3w.ini:/app/conf/config.default.ini
    ports:
      - "1080:8080"
```

