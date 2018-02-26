+++
date = "2017-12-27T16:38:18+08:00" title = "AMQ Topic Subsriber Model" categories = ["技术文章"] tags = ["ActiveMQ"]
+++



## Topic Subsriber模式 ##
订阅模式分为非持久订阅(Non-Durable Topic Subscribers)和持久订阅模式（Durable Topic Subscribers）


### 非持久订阅（Non-Durable Topic Subscribers） ###
- 生产者生产消息，谁订阅，谁就会收到
- 生产者生产消息，没有人订阅，消息废弃，当consumer启动连接时，废弃的消息不会再次被收到

代码如下：

``` java
package com.pgy.jms.sub;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

/**
 * @Date: Created in 27/12/2017 1:01 PM
 * @Author: pengganyu
 * @Desc:
 */

public class Producer {

    public static void main(String[] args) throws JMSException, InterruptedException {
        ConnectionFactory factory = new ActiveMQConnectionFactory(
            ActiveMQConnectionFactory.DEFAULT_USER, ActiveMQConnectionFactory.DEFAULT_PASSWORD,
            ActiveMQConnectionFactory.DEFAULT_BROKER_URL);

        Connection connection = factory.createConnection();
        connection.start();

        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        Topic topic = session.createTopic("hello");

        MessageProducer producer = session.createProducer(topic);

        int i = 0;
        while (true) {
            Thread.sleep(3000);
            producer.send(session.createTextMessage("hello" + i++));
        }
    }
}

```

``` java
package com.pgy.jms.sub;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

/**
 * @Date: Created in 27/12/2017 2:19 PM
 * @Author: pengganyu
 * @Desc:
 */

public class Cousmer {

    public static void main(String[] args) throws JMSException {
        TopicConnectionFactory factory = new ActiveMQConnectionFactory(
            ActiveMQConnectionFactory.DEFAULT_USER, ActiveMQConnectionFactory.DEFAULT_PASSWORD,
            ActiveMQConnectionFactory.DEFAULT_BROKER_URL);

        Connection connection = factory.createTopicConnection();
        connection.start();

        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        Topic topic = session.createTopic("hello");

        MessageConsumer consumer = session.createConsumer(topic);

        //        consumer.setMessageListener(message -> System.out.println(message));

        while (true) {
            TextMessage textMessage = (TextMessage) consumer.receive();
            System.out.println(textMessage.getText());

        }

    }
}

```

#### 说明 ####
- 生产者在不停地生产消息，如果消费者不启动，消费者是无法接收到消息的；（运行Producer）
- 消费者启动连接后，之前的消息是不会被接收到，启动后才可以接收到当前生产出来的消息（运行Consumer）
- 消费者断开连接后，无法接收到生产者生产的消息（停止consumer）
- 消费者再次连接后，之前丢失的消息无法继续再收到，只能接收到当前生产出来的消息（启动consumer）

### 持久订阅（Durable Topic Subscribers） ###

生产者的代码与非持久的相同，consumer的代码如下

``` java
package com.pgy.jms.sub;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

/**
 * @Date: Created in 27/12/2017 2:19 PM
 * @Author: pengganyu
 * @Desc:
 */

public class Cousmer1 {

    public static void main(String[] args) throws JMSException {
        TopicConnectionFactory factory = new ActiveMQConnectionFactory(
            ActiveMQConnectionFactory.DEFAULT_USER, ActiveMQConnectionFactory.DEFAULT_PASSWORD,
            ActiveMQConnectionFactory.DEFAULT_BROKER_URL);

        Connection connection = factory.createTopicConnection();
        connection.setClientID("consumer1");
        connection.start();

        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        Topic topic = session.createTopic("hello");

        MessageConsumer consumer = session.createDurableSubscriber(topic, "consumer1");


        //        consumer.setMessageListener(message -> System.out.println(message));

        while (true) {
            TextMessage textMessage = (TextMessage) consumer.receive();
            System.out.println(textMessage.getText());

        }

    }
}

```

``` java
package com.pgy.jms.sub;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

/**
 * @Date: Created in 27/12/2017 2:19 PM
 * @Author: pengganyu
 * @Desc:
 */

public class Cousmer2 {

    public static void main(String[] args) throws JMSException {
        TopicConnectionFactory factory = new ActiveMQConnectionFactory(
            ActiveMQConnectionFactory.DEFAULT_USER, ActiveMQConnectionFactory.DEFAULT_PASSWORD,
            ActiveMQConnectionFactory.DEFAULT_BROKER_URL);

        Connection connection = factory.createTopicConnection();
        // 与非持久订阅相比，需要设置ClientID
        connection.setClientID("consumer2");
        connection.start();

        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        Topic topic = session.createTopic("hello");
        // 与非持久订阅相比，需要用持久订阅方法去创建消费者
        MessageConsumer consumer = session.createDurableSubscriber(topic, "consumer2");

        while (true) {
            TextMessage textMessage = (TextMessage) consumer.receive();

            System.out.println(textMessage.getText());

        }

    }
}

```

#### 说明 ####
- 生产者在不停地生产消息，此时若没有人订阅，消息直接废弃（启动Producer）
- 消费者1启动，无法接收到之前Producer生产的消息，只能接收到当前的消息（启动Consumer1）
- 消费者2启动，也无法接收之前Producer生产的消息，只能接收到当前的消息（启动Consumer2）
- 中断消费者2，消费者1继续接收消息，消费者2无法接收消息（停止Consumer2）
- 启动消费者2，消费者1继续接收消息，消费者2可以接收到之前停止后丢失的消息，并可以继续接收当前消息（启动Consumer2）
- ActiveMQ是通过ClientID判断消息是否已经发给连接点，若消费者的ClientID相同，那么只会被某一个消费者接收到消息，而另外一个会报错
- 与非持久订阅模式的区别仅为设置了ClinetID及创建消费者使用createDurableSubscriber方法

