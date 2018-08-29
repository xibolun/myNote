+++
date = "2018-07-23T10:01:44+08:00" title = "RabbitMQ队列控制" categories = ["技术文章"] tags = ["rabbitmq"] toc = true
+++


## RabbitMQ队列控制

### 队列控制功能列表

- 延迟队列
- 删除队列
- 优先队列
- 重入队列
- 切换队列
- 定时队列

### 优先队列

- queue参数配置上面绑定x-max-priority参数
- consumer接收时也需要绑定x-max-priority参数
- message上面绑定priority值，若超出maxPriority则优先级按0进行处理
- 若queue一直被监听，此时好像优先级设定不起作用；即consumer模式不行，可以使用get模式

### 延迟队列 ###

- RabbitMQ 3.5.3版本官方出了一个延时加载的插件 [rabbitmq-delayed-message-exchange](https://github.com/rabbitmq/rabbitmq-delayed-message-exchange) 可以更方便解决这样的问题
- 也可以使用原生的ttl和dlx的方式进行处理，本文是以ttl+dlx的方式进行处理



[SpringBOOT 延时队列](https://juejin.im/post/5a12ffd451882578da0d7b3a)
[Go实现延时队列](https://studygolang.com/articles/12939)



![rabbitmq-dlx](http://oxmycii3v.bkt.clouddn.com/img/rabbitmq/rabbitmq-dlx.png)



- delay_exchange与delay_queue进行bind
- dlx exchange与dlx_queue进行bind
- delay_queue里面设置message ttl为10s，并将x-dead-letter-exchange为dlx
- 若delay_queue消息进行了以下的问题，则会被放至dlx当中
  - The message is rejected (basic.reject or basic.nack) with requeue=false,
  - The TTL for the message expires; 
  - The queue length limit is exceeded.



设置delayQueue,dlxQueue,delayExchange,dlx

``` java
  	@Bean
    Queue delayQueue() {
        Map<String, Object> param = new HashMap<>(2);
        param.put("x-dead-letter-exchange", RabbitConstant.DEAD_LETTER_EXCHANGE);
        // message ttl time 单位ms
        param.put("x-message-ttl", 10000);

        return new Queue(RabbitConstant.DELAY_QUEUE, false, false, false, param);
    }

    @Bean
    Queue dlxQueue() {
        return new Queue(RabbitConstant.DLX_QUEUE);
    }


    @Bean
    public DirectExchange deadLetterExchange() {
        return new DirectExchange(RabbitConstant.DEAD_LETTER_EXCHANGE);
    }

    @Bean
    public DirectExchange delayExchange() {
        return new DirectExchange(RabbitConstant.DELAY_EXCHANGE);
    }

    @Bean
    public Binding delayBind(Queue delayQueue, DirectExchange delayExchange) {
        return BindingBuilder.bind(delayQueue).to(delayExchange).with("");
    }

    @Bean
    public Binding dlxBind(Queue dlxQueue, DirectExchange deadLetterExchange) {
        return BindingBuilder.bind(dlxQueue).to(deadLetterExchange).with("");
    }
```

sender && receive

```java
	// sender
	public void ttlSend(Object object) {
        System.out.println("delayQueue sender---------------- " + object);
        rabbitTemplate.convertAndSend(RabbitConstant.DELAY_EXCHANGE, "", object);
    }

	// receiver
    @RabbitListener(queues = RabbitConstant.DLX_QUEUE)
    public void dlxReceive(Message object) {
        System.out.println("dlxQueue receive---------------- " + new String(object.getBody()));
    }
```

Test

```java
/**
 * @author admin
 * @version V1.0 31/05/2018 admin Exp $
 * @description
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
public class DlxTest {

    @Autowired
    private DirectSend directSend;

    @Test
    public void ttlDlxTest() {
        directSend.ttlSend("hello ttl && dlx");

        // 由于设置message ttl为10s，所以设置Test线程停留11s，保证dlx queue可以收到消息
        try {
            Thread.sleep(11000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

说明

- dead_letter_exchange与dlxQeueu没有绑定routeKey，若绑定了routeKey，那么在消息的配置参数【x-dead-letter-routing-key】也应该绑定对应的routeKey，这样才是一条通的消息链路
