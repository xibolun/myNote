---

date :  "2020年8月6日 上午11:46:17" 
title : "prometheus(一)环境搭建" 
categories : ["技术文章"] 
tags : ["prometheues"] 
toc : true
---



### 需求了解的几个概念

- 基础架构逻辑
- Discovery
- Alert
- Rule
- Exporter
- Target
- 



### Rule

关于RuleFile的解析

以下是一个rule file的定义内容

```
groups:
- name: hostStatsAlert
  rules:
  - alert: hostCpuUsageAlert
    expr: sum(avg without (cpu)(irate(node_cpu{mode!='idle'}[5m]))) by (instance) > 0.85
    for: 1m
    labels:
      severity: page
    annotations:
      summary: "Instance {{ $labels.instance }} CPU usgae high"
      description: "{{ $labels.instance }} CPU usage above 85% (current value: {{ $value }})"
  - alert: hostMemUsageAlert
    expr: (node_memory_MemTotal - node_memory_MemAvailable)/node_memory_MemTotal > 0.85
    for: 1m
    labels:
      severity: page
    annotations:
      summary: "Instance {{ $labels.instance }} MEM usgae high"
      description: "{{ $labels.instance }} MEM usage above 85% (current value: {{ $value }})"
```

