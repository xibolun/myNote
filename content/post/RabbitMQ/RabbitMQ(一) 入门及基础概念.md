+++
date = "2018-05-30T10:35:47+08:00" title = "RabbitMQ(一) 入门及基础概念" categories = ["技术文章"] tags = ["RabbitMQ"] toc = true

+++

- 什么是Exchange，为什么要用Exchange，四种模式有什么区别

- channel如何生成Queue，为什么会用Declare

- 什么是Route Key，为什么使用，机制是什么？

- Virtual Host是做什么使用的

- channel的方法解析

- 如何理解basicQos？保证了消息顺序发送，不会存在大的吞吐

- exchange、routingKey、queue、channel之间的关系是怎么样的

- delayQueue的参数同时添加ttl和expire为什么就再也接收不到消息？

- 为什么发送的时候没有使用queue，在接收的时候却需要queue，queue是怎么和channel结合的？

- Spring AMQP集成：https://docs.spring.io/spring-amqp/docs/2.0.3.RELEASE/reference/html/index.html

- [rabbitmq-cli-rabbitmqadmin]: http://www.cnblogs.com/xishuai/p/rabbitmq-cli-rabbitmqadmin.html?utm_source=gold_browser_extension

- web stomp: http://stomp.github.io/

- 如何配置mq的开机自启与关闭

- zeroMQ、rabbitMQ、ActiveMQ有什么区别及性能优势

# RabbitMQ(一) 入门及基础概念

![RabbitMQ-logo](http://www.rabbitmq.com/img/RabbitMQ-logo.svg)

## 安装配置

[Installing on Homebrew]: http://www.rabbitmq.com/install-homebrew.html



### 内置地址

- web界面：loalhost::15672   
- 默认用户名密码：guest/guest（若新增的用户名密码登陆失败，有可能是没有添加权限的tag）
- client： localhost:5672，默认virtual  host： /



### 命令

```
rabbitmqctl list_queues   #查询队列列表和消息
brew services restart rabbitmq  # 重启rabbitmq

```

### HTTP API

```
https://raw.githack.com/rabbitmq/rabbitmq-management/v3.7.5/priv/www/api/index.html
```



## 基础概念

### Virtual Hosts

### Channel

### Queue

- 用于存储消息的队列

### Exchange

### RoutingKey

### Plugins



### 

