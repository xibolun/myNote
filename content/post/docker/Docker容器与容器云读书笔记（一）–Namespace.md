---

date :  "2020-05-26T17:59:21+08:00" 
title : "Docker容器与容器云读书笔记（一）–Namespace" 
categories : ["docker"] 
tags : ["docker"] 
toc : true
---

## Docker容器与容器云读书笔记（一）–Namespace

Linux提供了一系列隔离的API

- `Mount`: 隔离文件系统挂载点，`CLONE_NEWNS`
- `UTS`: 隔离主机名和域名信息，`CLONE_NEWUTS`
- `IPC`: 隔离进程间通信，`CLONE_NEWIPC`
- `PID`: 隔离进程的ID，`CLONE_NEWPID`
- `Network`: 隔离网络资源，`CLONE_NEWNET`
- `User`: 隔离用户和用户组的ID，`CLONE_NEWUSER`

### UTC Namespace

创建`utc.c`文件如下：
```c
#define _GNU_SOURCE
#include <sys/wait.h>
#include <sys/utsname.h>
#include <sched.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define errExit(msg)        \
    do                      \
    {                       \
        perror(msg);        \
        exit(EXIT_FAILURE); \
    } while (0)

// 调用 clone 时执行的函数
static int childFunc(void *arg)
{
    struct utsname uts;
    char *shellname;
    // 在子进程的 UTS namespace 中设置 hostname
    if (sethostname(arg, strlen(arg)) == -1)
        errExit("sethostname");

    // 显示子进程的 hostname
    if (uname(&uts) == -1)
        errExit("uname");
    printf("uts.nodename in child:  %s\n", uts.nodename);
    printf("My PID is: %d\n", getpid());
    printf("My parent PID is: %d\n", getppid());
    // 获取系统的默认 shell
    shellname = getenv("SHELL");
    if (!shellname)
    {
        shellname = (char *)"/bin/sh";
    }
    // 在子进程中执行 shell
    execlp(shellname, shellname, (char *)NULL);

    return 0;
}
// 设置子进程的堆栈大小为 1M
#define STACK_SIZE (1024 * 1024)

int main(int argc, char *argv[])
{
    char *stack;
    char *stackTop;
    pid_t pid;

    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <child-hostname>\n", argv[0]);
        exit(EXIT_SUCCESS);
    }

    // 为子进程分配堆栈空间,大小为 1M
    stack = malloc(STACK_SIZE);
    if (stack == NULL)
        errExit("malloc");
    stackTop = stack + STACK_SIZE; /* Assume stack grows downward */

    // 通过 clone 函数创建子进程
    // CLONE_NEWUTS 标识指明为新进程创建新的 UTS namespace
    pid = clone(childFunc, stackTop, CLONE_NEWUTS | SIGCHLD, argv[1]);
    if (pid == -1)
        errExit("clone");

    // 等待子进程退出
    if (waitpid(pid, NULL, 0) == -1)
        errExit("waitpid");
    printf("child has terminated\n");

    exit(EXIT_SUCCESS);
}
```
编译
```shell
## gcc version

gcc -Wall  utc.c -o utc
```
执行后即可进入`myhost`的`ns`里面，`exit`即可退出；
```shell
[root@docker-ns pgy]# ./utc myhost
[root@myhost pgy]# hostname
myhost
[root@myhost pgy]# exit
exit
child has terminated
[root@docker-ns pgy]#
```
### IPC Namespace
```c
## 修改clone参数，添加CLONE_NEWIPC即可
 pid = clone(childFunc, stackTop, CLONE_NEWIPC |CLONE_NEWUTS | SIGCHLD, argv[1]);
```
编译
```shell
gcc -Wall  ipc.c -o ipc
```
测试
```shell
## 在原host里面查看并创建ipc
[root@docker-ns pgy]# ipcmk -Q
Message queue id: 0
[root@docker-ns pgy]# ipcs -q

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages
0xc4bdb217 0          root       644        0            0

[root@docker-ns pgy]# ipcmk -Q
Message queue id: 32769


### 添加ipc隔离
[root@docker-ns pgy]# ./ipc myhost
uts.nodename in child:  myhost
My PID is: 125325
My parent PID is: 125324
### 可以看到没有输出对应的ipc
[root@myhost pgy]# ipcmk -Q
Message queue id: 0
```
### PID Namespace
修改代码，在`clone`的时候，添加`CLONE_NEWPID`参数
```c
pid = clone(childFunc, stackTop, CLONE_NEWPID | CLONE_NEWIPC |CLONE_NEWUTS | SIGCHLD, argv[1]);
```
编译执行
```shell
[root@docker-ns pgy]# gcc -Wall  pid.c -o pid
### 查看当前shell的PID
[root@docker-ns pgy]# echo $$
122947
### 执行pid隔离，并查看PID，可以看到PID为1
[root@docker-ns pgy]# ./pid myhost
uts.nodename in child:  myhost
My PID is: 1
My parent PID is: 0
[root@myhost pgy]# echo $$
1
```
但是执行`ps`你还会发现其他的进程
```shell
[root@myhost pgy]# ps
   PID TTY          TIME CMD
122947 pts/0    00:00:00 bash
127135 pts/0    00:00:00 pid
127136 pts/0    00:00:00 bash
127663 pts/0    00:00:00 ps
```
因为`ps`读取的是原`host proc`下的文件，所以还需要做`mount`隔离
### Mount Namespace
```c
## 修改代码CLONE_NEWNS，由于mount是第一个namespace，所以名称为CLOUD_NEWNS
pid = clone(childFunc, stackTop, CLONE_NEWNS | CLONE_NEWPID | CLONE_NEWIPC | CLONE_NEWUTS | SIGCHLD, argv[1]);
```
编译测试
```shell
[root@docker-ns pgy]# gcc -Wall mount.c -o mount
[root@docker-ns pgy]# ./mount myhost
uts.nodename in child:  myhost
My PID is: 1
My parent PID is: 0
## 将proc目录挂载为proc类型的file system
[root@myhost pgy]# mount -t proc proc /proc
[root@myhost pgy]# ps
   PID TTY          TIME CMD
     1 pts/0    00:00:00 bash
    17 pts/0    00:00:00 ps
[root@myhost pgy]#
```

### User Namespace

```c
## 修改代码，添加CLONE_NEWUSER
pid = clone(childFunc, stackTop,  CLONE_NEWUSER | SIGCHLD, argv[1]);
```

编译测试

```shell
[root@docker-ns pgy]# ./utc myhost
uts.nodename in child:  myhost
My PID is: 129716
My parent PID is: 129715
[root@myhost pgy]# id
uid=0(root) gid=0(root) groups=0(root)
[root@myhost pgy]# id -u
0
[root@myhost pgy]# id -g
0
[root@myhost pgy]#
```

#### 映射

`docker`里面的用户和用户组是与宿主机进行映射；

```shell
[root@docker-ns ~]# docker ps | awk '{print $1}'
CONTAINER
c884b7311190
```

可以看到有一个 `docker`的进程，查一下它的`PID`

```shell
[root@docker-ns ~]# ps -aux | grep c88 | grep -v pts/0 | awk '{print $2}'
41986
```

查看它的 `user`与 `group`的映射 

```shell
[root@docker-ns ~]# cat /proc/41986/gid_map
         0          0 4294967295
[root@docker-ns ~]# cat /proc/41986/uid_map
         0          0 4294967295
```

这三列分别表示：

- `ID-inside-ns`：docker里面的ID
- `ID-outside-ns`：docker映射宿主机的ID
- `length`：长度范围

上面的结果的意思即为：`docker`的`root`与`docker-ns`主机的`root`进行了映射；

### Network Namespace

#### 单NS的情况

宿主机创建一个网络namespace

```shell
ip netns add nstest
```

添加一对“网线”

```shell
ip link add veth-a type veth peer name veth-b
```

为`veth-a`添加IP并启动

```shell
ip addr add  10.0.0.1/24 dev veth-a
ip link set dev veth-a up
```

将`veth-b`放入`nstest`当中，然后设置IP并启动

```shell
ip link set veth-b netns nstest
ip netns exec nstest ip addr add  10.0.0.2/24 dev veth-b
ip netns exec nstest ip link set dev veth-b up
```

添加完成后，测试ping

```shell
# veth-a
ping 10.0.0.2
# veth-b
ip netns exec nstest ping 10.0.0.1
```

对`veth-b`的操作前面都需要添加`ip netns exec`这样的命令，我们也可以进入一个`bash`的`netns`当中

```shell
# 前提是已经将veth-b添加至nstest当中
ip link set veth-b netns nstest
# 进入netns里面
ip netns exec nstest  bash
```

此时进入了一个`netns`环境当中，输入`exit`即可退出，我们可以在这里面对`veth-b`进行同样的操作；

```shell
ip addr add  10.0.0.2/24 dev veth-b
```

查看一下`link`状态，测试是否与`veth-a`想通；

```shell
[root@CloudBoot-dev-2-103 ~]# ip link list
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
16: veth-b@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether ca:31:5f:1d:00:10 brd ff:ff:ff:ff:ff:ff link-netnsid 0
[root@CloudBoot-dev-2-103 ~]# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.071 ms
```

清空ns

```shell
# 删除netns，同时会删除veth-b
ip netns del nstest
# 删除veth-a
ip link del veth-a
```

#### 两个NS怎么玩呢？

创建两个ns

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns add ns1
[root@CloudBoot-dev-2-103 ~]# ip netns add ns2
```

创建一根“网线”，  `veth-pairs`

```shell
[root@CloudBoot-dev-2-103 ~]# ip link add veth-a type veth  peer name veth-b
```

在`ns1`当中创建`veth-a`，在`ns2`当中创建`veth-b`

```shell
[root@CloudBoot-dev-2-103 ~]# ip link set veth-a netns ns1
[root@CloudBoot-dev-2-103 ~]# ip link set veth-b netns ns2
```

启动

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns1 ip link set dev veth-a up
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns2 ip link set dev veth-b up
```

配置IP

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth-a
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth-b
```

测试

```shell
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns1 ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=0.073 ms
......
[root@CloudBoot-dev-2-103 ~]# ip netns exec ns2 ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.061 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.077 ms
```

