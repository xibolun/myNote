---
date :  "2019-07-30T00:19:41+08:00" 
title : "SNMPTrap实战" 
categories : ["技术文章"] 
tags : ["运维"] 
toc : true
---

## 实战

### 环境准备

- 两台机器： 10.0.2.1(Manager)  192.168.1.8(Agent)
- net-snmp包安装 [net-snmp](http://www.net-snmp.org/download.html)

```
[root@9af74c959cc8 mibs]# snmpd -v

NET-SNMP version:  5.7.2
Web:               http://www.net-snmp.org/
Email:             net-snmp-coders@lists.sourceforge.net
```

### 配置Manager

##### 配置[Trap_Handlers](http://www.net-snmp.org/wiki/index.php/TUT:Configuring_snmptrapd#Trap_Handlers)

- 采用文件方式；写一个脚本将trap的message放至/tmp/a.log里面
- 详细查看  [Configure Snmptrap](http://www.net-snmp.org/wiki/index.php/TUT:Configuring_snmptrapd)

```shell
[root@cloudboot snmp]# vim /etc/snmp/snmptrapd.conf 
traphandle default /usr/local/bin/lognotify
authCommunity log,execute,net public
```

```shell
[root@cloudboot snmp]# vim /usr/local/bin/lognotify
[pengganyu@archlinux ~]$ 
#!/bin/sh

read host
read ip
vars=

while read oid val
do
  if [ "$vars" = "" ]
  then
    vars="$oid = $val"
  else
    vars="$vars, $oid = $val"
  fi
done

echo trap: $1 $host $ip $vars >> /tmp/a.log
```

##### 启动TrapListener

```
[root@cloudboot snmp]# snmptrapd -c /etc/snmp/snmptrapd.conf udp:1622
```

#### 配置Agent

##### 编写mib文件（直接使用net-snmp库里面的mib）

```
/usr/share/snmp/mibs/NET-SNMP-EXAMPLES-MIB
```

##### 发送trap

```
snmptrap -v 2c -c public 10.0.2.1:1622 "" NET-SNMP-EXAMPLES-MIB::netSnmpExampleHeartbeatNotification netSnmpExampleHeartbeatRate i 123456
```

发送trap至10.0.2.1的1622 UDP端口



### 其他

- [snmptt](http://www.snmptt.org/) Perl写的一个SNMP trap handler