---
date :  "2024-08-16 11:29:53+08:00"
title : "Go Prometheus取消go相关的metrics" 
categories : ["sre"] 
tags : ["monitor","go"] 
toc : true
description: Go Prometheus取消go相关的metrics
---

## Go Prometheus取消go相关的metrics

取消go 采集器的注册即可

```
	prometheus.Unregister(collectors.NewGoCollector())
```

