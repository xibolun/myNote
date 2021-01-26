---

date :  "2020-03-07T20:45:32+08:00" 
title : "k8s—JMX监控" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
---

### Jmx-Exporter

[Jmx Exporter](https://github.com/prometheus/jmx_exporter)是一个开源的`jvm`监控组件；原理是做为一个`java agent`去采集`jvm`运行状态的一些数据信息，并做为`http`服务暴露出来，集成至`Promethues`

### 实战

下载

```
curl -LO https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.14.0/jmx_prometheus_javaagent-0.14.0.jar
```

找一个应用的`jar`包，这里使用 [Arthas](https://arthas.gitee.io/)的一个demo jar

```shell
curl -LO curl -O https://arthas.aliyun.com/arthas-demo.jar
```

使用一个配置文件，官方有许多的[example-configs](https://github.com/prometheus/jmx_exporter/blob/master/example_configs/)

```shell
startDelaySeconds: 0
lowercaseOutputName: false
lowercaseOutputLabelNames: false
whitelistObjectNames: ["org.apache.cassandra.metrics:*"]
blacklistObjectNames: ["org.apache.cassandra.metrics:type=ColumnFamily,*"]
rules:
  - pattern: 'org.apache.cassandra.metrics<type=(\w+), name=(\w+)><>Value: (\d+)'
    name: cassandra_$1_$2
    value: $3
    valueFactor: 0.001
    labels: {}
    help: "Cassandra metric $1 $2"
    type: GAUGE
    attrNameSnakeCase: false
```

使用8088端口运行，注意路径匹配

```
java -javaagent:/data/jmx_prometheus_javaagent-0.14.0.jar=8088:/data/proemtheus-jmx-config.yaml -jar /data/arthas-demo.jar
```

### 集成Prometheus、Grafana

我将上面的应用做成一个`docker`，这样用起来比较方便

```dockerfile
FROM openjdk:8
RUN mkdir /data
ADD jmx_prometheus_javaagent-0.14.0.jar /data/jmx_prometheus_javaagent-0.14.0.jar
ADD arthas-demo.jar /data/arthas-demo.jar
ADD proemtheus-jmx-config.yaml /data/proemtheus-jmx-config.yaml
CMD java -javaagent:/data/jmx_prometheus_javaagent-0.14.0.jar=8088:/data/proemtheus-jmx-config.yaml -jar /data/arthas-demo.jar
```

使用`docker-compose`启动

```yaml
## jmx-exporter && prometheus && grafana
---
version: '2'
services:
  jmx-exporter:
    container_name: jmx-exporter
    ## 自己制作的一个jmx-exporter
    ## java -javaagent:/data/jmx_prometheus_javaagent-0.14.0.jar=8088:/data/proemtheus-jmx-config.yaml -jar /data/arthas-demo.jar
    image: registry.idcos.com/cloudpower/jmx-exporter:v1.0
    restart: always
    ports: 
      - "38080:8088"
  prometheus:
    container_name: prometheus
    image: prom/prometheus:latest
    restart: always
    ports:
      - "9090:9090"
    volumes:
    - /home/pengganyu/monitor/prometheus/prometheus.yml:/prometheus/prometheus.yml
    command: [ '--config.file=/prometheus/prometheus.yml', '--web.enable-lifecycle', '--web.enable-admin-api', '--storage.tsdb.retention=1y' ]
  nodeexporter:
    image: prom/node-exporter:v1.0.1
    container_name: nodeexporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    ports:
      - "9100:9100"
    labels:
      org.label-schema.group: "monitoring"
  cadvisor:
    image: google/cadvisor
    container_name: cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped
    ports:
      - "8080:8080"
    labels:
      org.label-schema.group: "monitoring"
  grafana:
    container_name: grafana
    user: root
    image: grafana/grafana
    environment:
      # 配置 Grafana 的默认根 URL。
      - GF_SERVER_ROOT_URL=http://192.168.100.107:20002
      # 配置 Grafana 的默认 admin 密码。
      - GF_SECURITY_ADMIN_PASSWORD=admin
    ports:
      - "20002:3000"
    volumes:
    - /tmp/grafana:/var/lib/grafana
```

```shell
docker-compose up -d 
```

使用`grafana template`

官方提供了许多的`template`，找一个拿着`id`号`load`即可

[jmx-grafana-template](https://grafana.com/grafana/dashboards?direction=desc&orderBy=downloads&search=jmx&dataSource=prometheus)

