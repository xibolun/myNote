+++
date = "2018-05-30T10:35:47+08:00" title = "RabbitMQ(二) HelloWorld" categories = ["技术文章"] tags = ["RabbitMQ"] toc = true
+++

## HelloWorld

### Producer

[send]: https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/java/Send.java



### Consumer

[recv]: https://github.com/rabbitmq/rabbitmq-tutorials/blob/master/java/Recv.java



### 说明

- TODO queue的设置需要非常注意 

```java
        channel.queueDeclare(QUEUE_NAME, true, false, false, null);
        channel.queueDeclare(QUEUE_NAME, false, false, false, null);
        channel.queueDeclare(QUEUE_NAME, true, true, false, null);
        channel.queueDeclare(QUEUE_NAME, true, false, true, null);
```

- 发布的时候的routingKey

```java
        channel.basicPublish("", QUEUE_NAME, null, "yunjikeji".getBytes());
```

- 不管producer发布了多少条消息，consumer可以一次性获取完

- 若consumer一直没有获取，那么消息一直会保存在queue当中，只若queue不是autoDelete和exclusive的

- 若需要保证消息永远不丢失，即RabbitMQ重启或者宕掉之后，消息还可以继续存留，需要在发布的时候设置消息为长连接的，同时需要将queue设置为durable

  ```java
  channel.queueDeclare(QUEUE_NAME, true, false, false, null);
  channel.basicPublish("", QUEUE_NAME, MessageProperties.PERSISTENT_TEXT_PLAIN, "yunjikeji".getBytes());
  ```

- 以上消息虽然没有使用Exchange，实际上使用了默认为""的Exchange



### SpringAMQP



