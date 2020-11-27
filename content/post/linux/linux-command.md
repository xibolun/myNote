---

date :  "2017-05-22T23:36:24+08:00" 
title : "linux命令学习" 
categories : ["技术文章"] 
tags : ["linux"] 
toc : true
---

每天一个linux命令
=================

会有不定期的更新，汇总........

文件及目录操作
--------------

### ls

1.  ls -l:列表显示当前目录下的文件
2.  ls -lu:根据文件名称正序排列文件
3.  ls -lt:根据文件修改时间倒序排列
4.  `ls -al --full-time` 查看时间详情
5.  ls -l \* | grep
    "^d^":列出当前文件目录下面的所有文件夹信息，其中d为linux当中的目录标识
6.  ls -l \* | grep "\^-":列出当前文件目录下面的所有文件信息
7.  ll -t --time-style=long-iso:以指定的时间格式显示文件
8.  ls -color\[=WHEN\]:其中when可以是never|always|auto
9.  ls -Sl : 根据文件大小进行倒序
10.  ls -Slr: 根据文件大小正序排序
11.  ``

### cd

1.  cd - ：返回上一次操作的目录
2.  cd !\$: 将一个命令的参数做为cd参数

### pwd

1.  pwd -P: 若当前目录为link,则显示link路径
2.  pwd -L: 若当前目录为link，显示软路径

### mkdir

1.  mkdir -v: 创建目录成功后显示信息
2.  mkdir -p: 递归创建目录
3.  mkdir -m: 创建带权限的目录

### rm

1.  rm -i : 交互式删除(interactive),每次删除都会有提示
2.  rm -f : 强制删除，没有提示
3.  rm -r : --recursive 递归删除
4.  rm -- -f : 删除以f开头的文件

### mv

1.  mv -t : target directory;将文件移动至目标目录 mv -t dir file...
2.  mv -f : force；若移动的文件已经存在，强制覆盖
3.  mv dir1 dir2:
    若dir2不存在，则将dir1重命名；若dir2存在，将dir1移动到dir2里面
4.  mv -b : backup,若文件存在，则根据备份策略将文件先备份

### cp

1.  cp -a : 是否覆盖copy，copy的时候两个文件的时间保持一致;相当于 -dR
2.  cp -l : copy一个link文件
3.  cp -R : copy整个目录

### touch

1.  touch -t : 指定文件的创建时间 touch -t 201211142223 log.log
2.  touch -r file1 file2: 将file2的时间更新为file1

### cat

1.  cat file1 file2 &gt; file: 合并多个文件
2.  cat &gt;&gt; file : 向文件里面继续添加内容，不会将原内容覆盖
3.  cat -n file1 file2 : 将file1添加行号后输入到file2当中
4.  cat -b file1 file2 : 将file1非空白行添加行号后输入到file2当中
5.  cat &gt; file &lt;&lt; EOF : 输入信息到file当中，输入EOF结束
6.  tac file : 将file的内容倒序显示

### nl

1.  nl -ba file : 将file的内容显示，并加上行号
2.  nl -bt file : 将file的内容显示，非空格的加上行号
3.  nl -nrz file: 将file的内容显示，非空格加上行号，行号默认以6位显示
4.  nl -nrz -w 3 file: 行号以3位数显示

### more

1.  more +n : 从第n行开始显示，如果more +3
2.  more -n : 定义每屏显示的行数

### head

1.  head file: 显示文件的前十行
2.  head -n 5 file: 显示文件的前五行
3.  head -n -5 file: 显示文件除最后五行之外的内容（mac不支持此命令）
4.  head -c 5 file: 显示文件5个字节
5.  head -c -5 file: 显示文件除最后5个字节之外的内容（mac不支持此命令）
6.  head -v file: 在文件内容的上面显示文件名称

### tail

1.  tail -n 6 file: 显示文件的最后5行
2.  tail file: 默认显示文件的最后十行
3.  tail -f file: 循环显示文件内容，若文件内容有更新，则会显示出来
4.  tailf -v file: 在文件内容上面显示文件名称

### tar

1.  tar本身没有压缩，需要调用其他的压缩命令实现
2.  tar -cvf log.tar log :
    将log目录打包，没有压缩；v显示过程，f指定压缩文件
3.  tar -czvf log.tar.gz log:
    将log目录打包，并压缩成支持gzip解压的包；打包文件还可以起名为tgz
4.  tar -czpvf log.tgz log: 将log里面的文件权限不变进行压缩
5.  tar --excule
6.  tar -cjvf log.tar.bz2 log: 将log目录打包，并压缩成支持bz2解压的包
7.  tar -ztf log.tgz: 显示tgz里面的文件列表
8.  tar -xvf log.tgz aaa.sql: 将压缩包当中的aaa.sql单独解压出来
9.  tar -xvf log.tgz: 解压tgz文件

文件查找命令
------------

### which

1.  如果一个命令在PATH当中，则将第一个搜索到的命令返回
2.  which -v : 查看命令的版本信息

### whereis

1.  说明： whereis搜索的是Linux数据库当中的文件信息，一周同步一次
2.  whereis -b nginx: 搜索nginx的可执行文件
3.  whereis -m nginx: 搜索nginx的帮助文件
4.  whereis -s nginx: 搜索nignx的源文件

### locate

1.  locate pwd: 搜索含有pwd的文件
2.  locate /etc/sh: 搜索/etc目录下面以sh开头的文件

### find

1.  find -amin -2: 查找系统当中最后2分钟被访问的文件
2.  find -atime -2: 查找系统当中最后2\*24小时访问的文件
3.  find -cmin -2: 查找系统当中最后2分钟被修改状态的文件
4.  find -ctime -2: 查找系统当中最后2\*24小时被修改状态的文件
5.  find -mmin -2: 查找系统当中最后2分钟被修改的文件
6.  find -mtime +2: 查找系统当中2\*24小时之前被修改的文件
7.  find -mtime -2: 查找系统当中2\*24小时之内被修改的文件
8.  find -mtime +2 | xargs rm -rf :
    查找系统当中2\*24小时之前被修改的文件，并删除他们
9.  find . -name "\*.log": 在当前目录下面根据名称递归查找文件
10.  find . -perm 777: 根据文件权限查找文件
11.  find . -type f -name "\*.log" : 根据文件类型查找文件
12.  find . -type d: 查找文件目录
13.  find . -type d | sort: 查询文件目录并排序
14.  find . -size +1000c -print:
    根据文件大小来查询，查找1k大小的文件，并进行打印输出
15.  find . -name "**SETTING**.sql" -exec ls -l {}  
    find与exec的套用；说明{}为find查出来的结果 命令必须以;结尾，\为转义
16.  find . -name "**SETTING**.sql" -exec rm -rf {}   查询文件并删除他们
17.  find . -name "**PORTAL**.sql" -exec grep "ROLE" {}  
    查询文件并grep文件当中的"ROLE"
18.  find . -name "**PORTAL**.sql" -exec mv {} /tmp  
    查询文件并将文件列表移动至/tmp目录;还可以使用cp命令进行拷贝
19.  find . -name "\[A-Z\]\*" : 查询文件名称以大写字母开头的文件，-name
    支持参数
20.  find / -name "\*" : 从系统的根目录开始查询文件列表信息，系统负荷较重
21.  find . -size +100c:
    查找大于100c的文件;c是bytes，M是以MB，k是以KB，G是以GB

文件和目录属性
--------------

-   包括：可变的、不可变的、可分享的、不可分享的
-   各文件的目录结构和属性参考[FHS](http://www.pathname.com/fhs/)

### linux目录结构说明

-   bin: 常用的命令存放
-   boot: 开机所需要的信息
-   dev: 设备相关的信息
-   etc: 系统设置
-   home: 操作者的目录
-   lib: 函数库
-   media: 媒体相关
-   mnt: 挂载
-   opt: 第三方软件
-   root: 系统管理员目录
-   sbin: root权限相关的系统设定操作
-   srv: 服务信息
-   tmp: 临时目录
-   lost+found:
-   proc: 临时目录，存放内存的数据及其他信息
-   sys: 核心系统所记录的内存数据

### 文件类型

-   s:
    数据接口文件sockets,client与服务器通信的文件，如果mysql.sock:srwxrwxrwx
-   -: 普通文件
-   d: 目录
-   c: 设备文件
-   l: link文件
-   b: 区块设备
-   p: pipe或FIFO文件类型

### 文件权限

#### chmod

-   chmod a+x file: 所有的用户和群组添加x权限
-   chmod ug+x file: 给当前用户和用户组添加x权限
-   chmod ug-x file: 给当前用户和用户组减去x权限
-   chmod u=x file: 将当前用户的file设置为x权限
-   chmod -R ug+x dir: 对目录进行添加权限

#### chgrp

-   chgrp -v root file: 修改file的属组
-   chgrp --reference file1 file2: 将file2的属组修改同file1一样
-   chgrp -R root dir: 修改dir目录下所有文件的属组为root
-   chgrp 20 file:
    根据id命令查询当中用户组的标识为20，通过标识码对文件进行修改属组操作

#### chown

-   chown admin: file: 修改file的属主为admin
-   chown :root file: 修改file的属组为root
-   chown admin:root file: 修改file的属主为admin，属组为root
-   chown -R root:root dir: 将dir目录的属主、属组都修改为root

### 其他

-   只要不以/开头的目录都是相对路径；以/开头的是绝对路径
-   linux打开data文件： last /var/log/wtmp
-   linux打开二进制文件： xxd等

系统管理
--------

#### systemctl

- `systemctl --version` : 版本信息

- `systemctl list-unit-files` : 查看所有可用的单元

- `systemctl list-units` : 查看所有运行单元

- `systemctl --failed` : 查看失败的单元

- `systemctl is-active tmp.mount|smb.service|dbus.socket` : 是否active

- `systemctl is-enabled tmp.mount|smb.service|dbus.socket` : 是否enabled

- `systemctl enable|disable tmp.mount|smb.service|dbus.socket` : 设置开机启动|不启动

- `systemctl --type=mount` : 查看挂载点列表

- `systemctl --type=service` : 查看服务列表

- `systemctl --type=socket` : 查看服务列表

- ``systemctl status|reload|restart|start|stop|kill  tmp.mount|smb.service|dbus.socket` : 生命周期管理

- `systemctl cat docker.service|tmp.mount|dbus.socket` : 查看配置

- `systemctl show docker.service|tmp.mount|dbus.socket` : 查看配置细节 

- `systemctl list-dependencies docker.service|tmp.mount|dbus.socket` : 查看依赖列表

- `systemd-analyze critical-chain docker.service|tmp.mount|dbus.socket` : 查看配置细节 

- 分析启动进程

  ```shell
  [root@10-0-2-7 ~]# systemd-analyze
  Startup finished in 1.601s (kernel) + 2.817s (initrd) + 32.876s (userspace) = 37.296s
  ```

- 分析

### df

-   df是查看系统磁盘的使用情况
-   df -h: 以human的方式显示磁盘大小信息,以1024为单位进行转换
-   df -H: 以1000为单位进行转换
-   df -t ext3: 显示指定类型的磁盘
-   df -T: 列出文件系统类型

### du

-   du是查看文件和目录的磁盘使用情况
-   du -ah: 列出当前目录下所以文件和目录的大小
-   du -h file: 显示file大小
-   du -h dir: 显示dir大小
-   du -sh: 显示总和
-   du -c file1,file2: 显示每一个文件的大小，并统计总和
-   du -ah | sort -nr:
    根据文件的空间大小进行倒序排列，不加nr为正序排列，其中r为reverse

### top

#### 第一行 top

-   10:53:42: 系统时间
-   up 24 days: 开机24天
-   1 user: 当前有一个人登陆
-   load average: 负载使用情况

#### 第二行 Tasks

-   65 totle: 总共有65个进程
-   1 running: 有一个running的
-   63 sleeping: 63个在休眠
-   0 stopped: 0个停止的
-   0 zombie: 0个僵尸进程

#### 第三行 %Cpu(s)

-   0.0 us: 用户空间占用CPU的百分比
-   3.4 sy: 内核空间占用CPU的百分比
-   0.0 ni: 改变过优先级的进程占用CPU的百分比
-   90 id: 空间CPU百分比
-   0.0 wa: IO等待占用CPU的百分比
-   0.0 hi: Hardware IRQ 硬中断占用CPU百分比
-   0.2 si: Software Interrupts 软件中断占用CPU百分比

#### 第四行 内存状态

-   total: 总共内存大小，物理内存
-   free: 空间内存大小
-   used: 已用内存大小
-   buff/cache: 缓存使用大小

#### 第五行 Swap信息

-   Swap指当内存不够用的时候，会将一部分硬盘转换为内存使用
-   total: 交换区容量
-   used: 使用总量
-   free: 空间总量
-   cached: 缓存总量

#### 第六行 空

#### 第七行 各进程的状态监控

#### 操作技巧

-   b : 高亮当前正在running的进程
-   1 : 可以切换主机不同CPU的监控信息
-   x : 对CPU的占用量排序列高亮显示
-   k : 按k，然后输入进程id，可以kill此进程
-   shift + &gt; 或shift +&lt;:
    向右或向左改变排序列，默认是以%CPU进行排序
-   top -c : 监控的command列显示完整的命令
-   top -n 2: 更新两次后终止刷新
-   top -d 3: 以3s为周期进行更新
-   top -p id: 显示指定id号的进程

### free

-   free : 显示系统内存使用和空间情况
-   free -m : 以MB显示
-   free -k : 以KB显示
-   free -b : 以Byte显示
-   free -g : 以GB为单位显示
-   free -t : 显示内存总和列
-   free -V : 显示版本信息
-   free -s 10 : 10s刷新一次内存
-   cat /proc/meminfo : 查看系统内存情况

### lsof

-   lsof -c java : 打开java进程正在使用的文件
-   lsof -u root: 打开某个用户正在使用的文件
-   lsof -u ^root^ : 打开除了某个用户正在使用的文件
-   lsof -i : 列出所有的网络连接
-   lsof -p PID:  列出进程打开的文件
-   lsof -i tcp/udp: 列出所有的tcp、udp网络连接信息
-   lsof -i:8080 : 列出8080端口被哪个应用使用
-   lsof -i tcp:80: 列出指定的tcp协议80端口

### pmap

- pmap PID: 查看进程的内存使用状态

### sar

部署

```
## 安装
yum install sysstat 
## 配置文件修改
echo '----
# Should sadc collect system activity informations? Valid values
# are "true" and "false". Please do not put other values, they
# will be overwritten by debconf!
ENABLED="true"
----' >> /etc/default/sysstat
## 重启服务
systemctl restart sysstat.service
```

使用

```
sar -u 1 3 ## 每隔1s，查看cpu的情况三次
sar -d ## 硬盘
sar -A ## 所有信息
sar -r ## 内存
sar -p ## 活动页page
sar -q ## 队列
sar -w ## 系统交换情况
```



## 网络相关

### netstat

```
## t-tcp  l-listening p-program
netstat -tlp 
```



文本处理
----

### grep ###
- `grep -v` : 排除某些选项
- `grep ^u` : 匹配以u开头的内容
- `grep ^[^u]` : 匹配以非u开头的内容
- `grep hat$` : 以hat结尾
- `grep -E "ed|at"` : 正则多条件匹配
- `grep "Inspection" error.log -c` : 统计数量
- `grep "Inspection" error.log -n` : 打印匹配行数
- `grep "Inspection" error.log -i` : 忽略大小写匹配

### sort ###
- `sort test.txt -r` : 倒序排列， reverse
- `sort test.txt -k n` : 指定排序的列

### uniq ###
- `uniq -c test.txt1` : 统计重复数据
- `uniq -u test.txt1` : 只输出不重复信息
- `uniq -d test.txt1` : 只输出重复的信息

#### [sed](https://www.gnu.org/software/sed/manual/sed.html)

常用参数

- `n` ：使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN 的数据一般都会被列出到终端上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
- `e` ：直接在命令列模式上进行 sed 的动作编辑；
- `f` ：直接将 sed 的动作写在一个文件内， -f filename 则可以运行 filename 内的 sed 动作；
- `r` ：sed 的动作支持的是延伸型正规表示法的语法。(默认是基础正规表示法语法)
- `i` ：直接修改读取的文件内容，而不是输出到终端。

常用function

- `a` ：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
- `c` ：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
- `d` ：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
- `i` ：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
- `p` ：列印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
- `s` ：取代，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配正规表示法！例如 1,20s/old/new/g 就是啦！

样例：

- `sed -i 's/ws:\/\//wss:\/\//g' test.sh`：将test.sh里面的`ws://`替换为`wss://`; `-i`修改文件内容

- `sed -e 's/ws:\/\//wss:\/\//g' test.sh`：将`test.sh`为内容，执行`-e`后面命令，输出至stdout

- `sed -e '1,2d' test.sh `: 删除1-2行的数据

  

高级
----

### crontab

-   crontab file: 如何添加一个cron: crontab file:
    file是写的cron定时脚本；系统会将file的定时任务提交，并以当前用户的名称存放于/var/spool/cron下面
-   crontab -l : 查询当前用户的定时任务信息
-   cat /etc/crontab: 里面记录着crontab的用法
-   service crontab status|stop|restart|start: service
    crontab服务的生命周期命令
-   crontab -r : 删除当前用户的cron

#### linux唯一标识：

```
cat /sys/class/dmi/id/product_uuid
```

### vmstat

- `vmstat 1 3 ` : 每1钟输出process、memory等信息详情，总共输出3次，
- `vmstat 1`:  若count为空，则会一直输出

#### iostat

```shell
-C 显示CPU使用情况
-d 显示磁盘使用情况
-k 以 KB 为单位显示
-m 以 M 为单位显示
-N 显示磁盘阵列(LVM) 信息
-n 显示NFS 使用情况
-p[磁盘] 显示磁盘和分区的情况
-t 显示终端和CPU的信息
-x 显示详细信息
-V 显示版本信息
```

```shell
# iostat -d  -x -k 1 1
Linux 3.10.0-229.el7.x86_64 (res-10-0-0-142)    10/29/2019      _x86_64_        (4 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
vda               0.00     0.19    1.02   31.48     4.07   529.77    32.86     0.04    1.22   16.05    0.74   0.31   1.01
vdb               0.00     0.01    0.97    0.23     2.91     3.37    10.48     0.00    1.37    1.59    0.43   0.07   0.01

```

查看所有

```shell
# iostat 
Linux 3.10.0-229.el7.x86_64 (res-10-0-0-142)    10/29/2019      _x86_64_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           4.77    0.00    0.74    0.22    0.03   94.24

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
vda              32.50         4.07       529.77    3819959  497494630
vdb               1.20         2.91         3.37    2736630    3162946
```



```shell
%user：CPU处在用户模式下的时间百分比。
%nice：CPU处在带NICE值的用户模式下的时间百分比。
%system：CPU处在系统模式下的时间百分比。
%iowait：CPU等待输入输出完成时间的百分比。
%steal：管理程序维护另一个虚拟处理器时，虚拟CPU的无意识等待时间百分比。
%idle：CPU空闲时间百分比。
```



#### ldd

查看程序依赖库

```shell
# ldd /usr/bin/sar
        linux-vdso.so.1 =>  (0x00007fffb3f8f000)
        libc.so.6 => /lib64/libc.so.6 (0x00007fb08f569000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fb08f931000)
```

#### fuser

查看程序的运行和被哪个用户使用情况

```shell
# fuser -u -m /usr/bin/redis-server
```

#### 进程相关

```
## 进程查看
ps -ef | grep zabbix_agentd

## 查看进程下的线程
ps mp pid -o THREAD,tid
## 统计进程下的线程数
cat /proc/15176/status | grep -i Threads

## 子进程
pstree pid
ps -axjf | grep 2018
```

