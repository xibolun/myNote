---
date :  "2019-07-30T00:19:41+08:00" 
title : "NMAP使用" 
categories : ["技术文章"] 
tags : ["运维"] 
toc : true
---

## Nmap

[nmap](https://nmap.org/) （Network Mapper）是一个网络工具，用于网络发现和安全审计

### 使用详解

仅列出需要发现的目标

```shell
[root@10-0-2-7 ~]# nmap -sL 10.0.1.1-3

Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-20 21:25 CST
Nmap scan report for 10.0.1.1
Nmap scan report for 10.0.1.2
Nmap scan report for 10.0.1.3
Nmap done: 3 IP addresses (0 hosts up) scanned in 0.25 seconds
```

### 设备发现

- 列出活着的设备 `nmap 10.0.1.1-3`
- 不扫描端口：`nmap -sn 10.0.1.1-3`
- 排除某些设备：`nmap -sn 10.0.1.1-3 --exclude 10.0.1.1,10.0.1.2 `1