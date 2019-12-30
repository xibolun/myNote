---
date :  "2019-12-18T17:41:06+08:00" 
title : "IPMI&Tool" 
categories : ["技术文章"] 
tags : ["linux"] 
toc : true
---

### IPMI

IPMI(Intelligent Platform Management Interface)，智能平台管理接口，1998年由Intel、Dell等各大服务厂商提出，成为了一种开放的规范标准，可以通过网络控制服务器，包括开关机、重启、引导、温度、电压、事件等；并且这个玩意厉害在于它是独立于服务器电源的，只要通电，就可以控制设备信息；即系统关闭了，只要IPMI还通着电就能够将它起动起来。

IPMI有自己的IP、可以是静态的也可以是DHCP的，网关，掩码、用户、权限等；

### IPMITool 

[ipmitool](https://github.com/ipmitool/ipmitool)一个开源的IPMI管理工具，有本地和远程两种使用方式

```shell
# ipmitool lan -H {IP} -U {USENAME} -P {PASSWORD} args  // 远程模式
# ipmitool args		// 本地模式
```

#### 信息查看

- BMC

```shell
ipmitool mc info
ipmitool mc reset warm/cold
```

- 查看fru detail

```shell
ipmitool fru print
```

- 查看lan信息

```shell
ipmitool lan  print
```

#### chassis

```shell
# ipmitool chassis
Chassis Commands:  status, power, identify, policy, restart_cause, poh, bootdev, bootparam, selftest
```

```shell
ipmitool [chassis] power status
pmitool [chassis] power on
pmitool [chassis] power off
pmitool [chassis] power status
```

#### 设置下一次引导 

```shell
# ipmitool chassis bootdev
bootdev <device> [clear-cmos=yes|no]
bootdev <device> [options=help,...]
  none  : Do not change boot device order
  pxe   : Force PXE boot
  disk  : Force boot from default Hard-drive
  safe  : Force boot from default Hard-drive, request Safe Mode
  diag  : Force boot from Diagnostic Partition
  cdrom : Force boot from CD/DVD
  bios  : Force boot into BIOS Setup
  floppy: Force boot from Floppy/primary removable media
```

#### SEL(system event log)

```shell
ipmitool sel elist   // 查看扩展日志
ipmitool sel list		// 查看日志列表
ipmitool sel clear	// 清除日志
ipmitool sel [info]	// 查看日志基本信息
```

#### 传感器

```shell
ipmitool sdr list				// 信息列表
ipmitool sdr type list	// 传感器类型列表，及其对应的16进制数据
ipmitool sdr type Processor|Temperature|Battery...... 	// 查看对应类型的传感器信息
ipmitool sdr type 0x07|0x01|0x29												// 也可以根据对应的类型的16进制查看
```

#### 设置IP

```shell
ipmitool lan print 1		// 1代表channel
ipmitool lan set 1 ipsrc [ static | dhcp ] 
ipmitool lan set 1 ipaddr {YOUR DESIRED IP}
ipmitool lan set 1 netmask {YOUR NETMASK}
ipmitool lan set 1 defgw ipaddr {YOUR gateway}
```

#### channel

```shell
ipmitool channel info 1 // 查看channel信息
```

#### 设置用户

```shell
ipmitool user set name 7 root  // 添加/修改userid=7、username=root的用户
ipmitool user set password 7   // 添加/修改userid=7的用户密码
ipmitool user enable 7					// 开启用户
ipmitool user disable 7					// 关闭用户
ipmitool user test 7 16/20 {Password} // 测试用户是否生效
ipmitool user priv 7 0x4 1 			// 为userid=7的用户在channel=1当中配置超级管理员(0x4)的权限
```

#### 重置带外

```
ipmitool mc reset warm  ## 重置bmc，不重启
ipmitool mc reset cold  ## 重启bmc

ipmicfg -fde    ## 恢复出厂设置，包括网络设置
ipmicfg -fd			## 恢复出厂设置，除了网络设置
```

### 一些常见的错误

```shell
# ipmitool lan -H xxx -U xx -P xx power status
Could not open socket!
```



用户名或密码错误

```shell
ipmitool -I lanplus -H xxxx -U root -P xxx fru list 0
Unable to establish IPMI v2 / RMCP+ session
```

