---

date :  "2020-05-27T09:13:38+08:00" 
title : "Docker容器与容器云读书笔记（二）–CGroup" 
categories : ["技术文章"] 
tags : ["docker"] 
toc : true
---

## Docker容器与容器云读书笔记（二）–CGroup

### 术语

需要先知道几个术语

- task 任务：即进程或者线程，`tasks`里面有许多的进程号码

```
[root@docker-ns 41986]# ll /sys/fs/cgroup/cpu/tasks
-rw-r--r-- 1 root root 0 Apr  8  2020 /sys/fs/cgroup/cpu/tasks
```

- cgroup 控制组：对各个资源进行控制，每个资源下面可以分为多个子系统和`task`

```shell
[root@docker-ns 41986]# ls /sys/fs/cgroup/
blkio  cpu  cpuacct  cpu,cpuacct  cpuset  devices  freezer  hugetlb  memory  net_cls  net_cls,net_prio  net_prio  perf_event  pids  systemd
```

- subsystem 子系统：`sys/fs/cgroup`目录下面的子系统
- hierarchy 层级：由多个`cgroup`组成，与子系统绑定，对资源进行控制

### 实战

#### CPU限制

下面这段代码是一个死循环，会把`cpu`跑满，我们对容器的`cpu`进行控制

```c
int main(void)
{
    int i = 0;
    for(;;) i++;
    return 0;
}
```

编译运行

```shell
[root@docker-ns cgroup]# gcc -Wall cpu.c -o cpu
[root@docker-ns cgroup]# ./cpu
## TOP里面看到cpu已经到100%了
	PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
  7543 root      20   0    4212    352    276 R 100.0  0.0   0:15.79 cpu
```

在`/sys/fs/cgroup/cpu`目录下创建一个目录，看看会发生什么效果？

```
[root@CloudPower-dev-2-119 cpu]# mkdir /sys/fs/cgroup/cpu/cg1
[root@CloudPower-dev-2-119 cpu]# ll cg1
total 0
-rw-r--r-- 1 root root 0 Nov 26 13:53 cgroup.clone_children
--w--w--w- 1 root root 0 Nov 26 13:53 cgroup.event_control
-rw-r--r-- 1 root root 0 Nov 26 13:53 cgroup.procs
-r--r--r-- 1 root root 0 Nov 26 13:53 cpuacct.stat
-rw-r--r-- 1 root root 0 Nov 26 13:53 cpuacct.usage
-r--r--r-- 1 root root 0 Nov 26 13:53 cpuacct.usage_percpu
-rw-r--r-- 1 root root 0 Nov 26 13:53 cpu.cfs_period_us
-rw-r--r-- 1 root root 0 Nov 26 13:53 cpu.cfs_quota_us
-rw-r--r-- 1 root root 0 Nov 26 13:53 cpu.rt_period_us
-rw-r--r-- 1 root root 0 Nov 26 13:53 cpu.rt_runtime_us
-rw-r--r-- 1 root root 0 Nov 26 13:53 cpu.shares
-r--r--r-- 1 root root 0 Nov 26 13:53 cpu.stat
-rw-r--r-- 1 root root 0 Nov 26 13:53 notify_on_release
-rw-r--r-- 1 root root 0 Nov 26 13:53 tasks
```

为什么会多出那么多的文件呢？`cg1`便是一个`cpu`的`cgroup`，这个乃是系统自动生成，为控制`CPU`的使用的；

其中`cpu.cfs_quota_us`即为限制`cpu`的阈值

```shell
## 设置阈值
[root@docker-ns cg1]# echo 20000 > /sys/fs/cgroup/cpu/cg1/cpu.cfs_quota_us
## 设置生效的线程
[root@docker-ns cg1]# echo 7543 > /sys/fs/cgroup/cpu/cg1/tasks
## 再运行TOP即可看到cpu控制在20%了
PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
  7543 root      20   0    4212    348    276 R  19.9  0.0   0:33.12 cpu
```

#### memroy限制

```shell
[root@docker-ns ~]# mkdir /sys/fs/cgroup/memory/mem1
[root@docker-ns ~]# cat /sys/fs/cgroup/memory/mem1/memory.limit_in_bytes
9223372036854771712  // 8
[root@docker-ns ~]# echo 64k >  /sys/fs/cgroup/memory/mem1/memory.limit_in_bytes
[root@docker-ns ~]# echo 7543 > /sys/fs/cgroup/memory/mem1/tasks
```

若进程`7543`的阈值超过`64k`会被`kill`

#### disk限制

```shell
[root@docker-ns ~]# mkdir /sys/fs/cgroup/blkio/disk
[root@docker-ns ~]# cat  /sys/fs/cgroup/blkio/disk/blkio.throttle.read_bps_device
[root@docker-ns ~]# echo '8:0 1048576'  > /sys/fs/cgroup/blkio/io/blkio.throttle.read_bps_device
[root@docker-ns ~]# echo 7543 > /sys/fs/cgroup/blkio/disk/tasks
```

