+++
date = "2018-06-25T17:30:28+08:00" title = "RabbitMQ(三) Exchange Modes" categories = ["技术文章"] tags = ["RabbitMQ"] toc = true

+++

## Exchange Modes

### Direct

- direct 按着指定的路由发送至对应的queue，若routingKey不指定，则使用默认的""

![exchange-direct](https://www.rabbitmq.com/img/tutorials/intro/exchange-direct.png)

- 可以使用相同的routingKey绑定不同的Queues，这种形式像fanout模式一样

![direct-exchange-multiple](http://www.rabbitmq.com/img/tutorials/direct-exchange-multiple.png)

### Fanout

- 路由模式，设置routingKey是没有用的，会发送消息至所有与fanoutExchange绑定的queues里面去
- 若FanoutExchange改变了绑定的Queue，RabbitMQ不会内部刷新，需要手工删除

![exchange-fanout](https://www.rabbitmq.com/img/tutorials/intro/exchange-fanout.png)

### Topic

- 发送时定义什么样的routingKey，则接收的时候按照routingKey的规则去接收
- topic模式下的routingKey可以是表达式，用于多个Queue进行接收
- 若TopicExchange改变了绑定的RoutingKey，RabbitMQ不会内部刷新，需要手工删除

#### \*  &  \#

```
/**
 * Q1    hello*
 * Q2    hello#
 * 2.hello.2        Q1
 * hello.2          Q1 Q2
 * hello.to.hello   Q2
 * null             无
 * ""               无
 * 2hello           无
 * hello2           无
 */
```

- \* 只匹配一个字符
- \# 匹配多个字符
- 若存在多个匹配字符，则\*就不会命中，只有\#会命中
- hello2与2hello不会命中说明不是like，而是单词的full匹配；

### Demo

[springboot-rabbit](https://github.com/kedadiannao220/springboot-exp/tree/master/springboot-rabbit)







