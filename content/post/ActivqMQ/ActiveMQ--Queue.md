+++
date = "2017-08-01T23:36:24+08:00" title = "ActiveMQ Queue Model" categories = ["技术文章"] tags = ["ActiveMQ"] toc = true
+++

# ActiveMQ是干什么的？

-   [Apache ActiveMQ](http://activemq.apache.org/)
    是一个开源的消息集成服务
-   支持多语言，支持[JMS1.1](http://www.oracle.com/technetwork/java/jms/index.html)
    J2EE1.4
-   首先需要了解什么是JMS和JMS相关的API：[Java Message Service
    Concepts](http://docs.oracle.com/javaee/6/tutorial/doc/bncdq.html)

# Queue模式

## 简单demo ##
### 下载ActiveMQ，并运行 [ActiveMQ Getting Started](http://activemq.apache.org/version-5-getting-started.html)

### 说明 activemq-all的jar包需要使用jdk1.8

### pom.xml

``` xml
<dependency>
    <groupId>org.apache.activemq</groupId>
    <artifactId>activemq-all</artifactId>
    <version>5.15.0</version>
</dependency>
```

``` java
package com.pgy.jms.p2p;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

/**
 * @Date: Created in 27/12/2017 2:19 PM
 * @Author: pengganyu
 * @Desc:
 */

public class Cousmer {

    public static void main(String[] args) throws JMSException {
        ConnectionFactory factory = new ActiveMQConnectionFactory(
            ActiveMQConnectionFactory.DEFAULT_USER, ActiveMQConnectionFactory.DEFAULT_PASSWORD,
            ActiveMQConnectionFactory.DEFAULT_BROKER_URL);

        Connection connection = factory.createConnection();
        connection.start();//若connection不启动，不会进行连接消费

        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        Queue queue = session.createQueue("hello");

        MessageConsumer consumer = session.createConsumer(queue);

        //        consumer.setMessageListener(message -> System.out.println(message));

        while (true) {
            TextMessage textMessage = (TextMessage) consumer.receive();

            System.out.println(textMessage);

        }

    }
}

```

``` java
package com.pgy.jms.p2p;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;

/**
 * @Date: Created in 27/12/2017 1:01 PM
 * @Author: pengganyu
 * @Desc:
 */

public class Producer {

    public static void main(String[] args) throws JMSException {
        ConnectionFactory factory = new ActiveMQConnectionFactory(
            ActiveMQConnectionFactory.DEFAULT_USER, ActiveMQConnectionFactory.DEFAULT_PASSWORD,
            ActiveMQConnectionFactory.DEFAULT_BROKER_URL);

        Connection connection = factory.createConnection();

        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

        Queue queue = session.createQueue("hello");

        MessageProducer producer = session.createProducer(queue);

        for (int i = 0; i < 100; i++) {
            TextMessage tx = session.createTextMessage("hello" + i);
            producer.send(tx);
        }

        connection.close();

    }
}

```

### 说明 ###
- 当生产者生产消息时，没有consumer连接时，消息直接废弃
- consumer类当中，若Connection若未start，则不会得到消息
- 当生产者生产消息时，若有n个consumer连接时，消息被平均分配到每一个consumer里面，即每个consumer接收到 sum(message)/n



## 另一个demo ##


### 消费者

``` java
package com.pgy.mq;

import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by admin on 25/07/2017.
 */
public class Consumer {
    private static String        USER_NAME   = ActiveMQConnection.DEFAULT_USER;

    private static String        PASSWORD    = ActiveMQConnection.DEFAULT_PASSWORD;

    private static String        BROKEN_URL  = ActiveMQConnection.DEFAULT_BROKER_URL;

    AtomicInteger                count       = new AtomicInteger(0);

    ActiveMQConnectionFactory    connectionFactory;

    Connection                   connection;

    Session                      session;

    ThreadLocal<MessageConsumer> threadLocal = new ThreadLocal();

    public void init() {
        try {
            connectionFactory = new ActiveMQConnectionFactory(USER_NAME, PASSWORD, BROKEN_URL);
            connection = connectionFactory.createConnection();
            connection.start();
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        } catch (JMSException e) {
            e.printStackTrace();
        }
    }

    public void getMessage(String disName) {
        Queue queue = null;
        try {
            queue = session.createQueue(disName);
            MessageConsumer messageConsumer = null;

            if (threadLocal.get() != null) {
                messageConsumer = threadLocal.get();
            } else {
                messageConsumer = session.createConsumer(queue);

                threadLocal.set(messageConsumer);
            }

            while (true) {
                Thread.sleep(1000);

                TextMessage textMessage = (TextMessage) messageConsumer.receive();

                if (textMessage != null) {
                    textMessage.acknowledge();

                    System.out.println(Thread.currentThread().getName() + "获取消息:"
                                       + textMessage.getText() + "-----" + count.getAndIncrement());
                } else {
                    break;
                }

            }
        } catch (JMSException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

}

```

### 生产者

``` java
package com.pgy.mq;

import org.apache.activemq.ActiveMQConnection;
import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by admin on 25/07/2017.
 */
public class Producter {

    private static String            USER_NAME   = ActiveMQConnection.DEFAULT_USER;

    private static String            PASSWORD    = ActiveMQConnection.DEFAULT_PASSWORD;

    private static String            BROKEN_URL  = ActiveMQConnection.DEFAULT_BROKER_URL;

    static AtomicInteger             count       = new AtomicInteger(0);

    static ActiveMQConnectionFactory connectionFactory;

    static Connection                connection;

    static Session                   session;

    static ThreadLocal<MessageProducer>     threadLocal = new ThreadLocal();

    public static void main(String[] args) {
        init();
        sendMessage("hello");
    }

    public static void init() {

        try {
            connectionFactory = new ActiveMQConnectionFactory(USER_NAME, PASSWORD, BROKEN_URL);
            connection = connectionFactory.createConnection();

            connection.start();

            session = connection.createSession(true, Session.SESSION_TRANSACTED);
        } catch (JMSException e) {
            e.printStackTrace();
        }

    }

    public static void sendMessage(String disName) {
        try {
            Queue queue = session.createQueue(disName);

            MessageProducer messageProducer = null;

            if (threadLocal.get() != null) {
                messageProducer = threadLocal.get();
            } else {
                messageProducer = session.createProducer(queue);

                threadLocal.set(messageProducer);
            }

            while (true) {
                Thread.sleep(10000);

                int sum = count.getAndIncrement();

                TextMessage textMessage = session.createTextMessage(
                    Thread.currentThread().getName() + "helloWorld, times = " + sum);

                messageProducer.send(textMessage);

                session.commit();
            }

        } catch (JMSException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

}

```

### 生产消息

``` java
package com.pgy.mq;

/**
 * Created by admin on 25/07/2017.
 */
public class TestMProducter {

    public static void main(String[] args) {

        Producter producter = new Producter();
        producter.init();

        TestMProducter testMProducter = new TestMProducter();

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        new Thread(testMProducter.new ProducterMq(producter)).start();
        new Thread(testMProducter.new ProducterMq(producter)).start();
        new Thread(testMProducter.new ProducterMq(producter)).start();
        new Thread(testMProducter.new ProducterMq(producter)).start();
        new Thread(testMProducter.new ProducterMq(producter)).start();

    }

    private class ProducterMq implements Runnable {
        Producter producter;

        public ProducterMq(Producter producter) {
            this.producter = producter;
        }

        @Override
        public void run() {
            while (true) {
                producter.sendMessage("pengganyu");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}

```

### 消费消息

``` java
package com.pgy.mq;

/**
 * Created by admin on 01/08/2017.
 */
public class TestConsumer {

    public static void main(String[] args) {

        Consumer consumer = new Consumer();
        consumer.init();

        TestConsumer testMProducter = new TestConsumer();

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        new Thread(testMProducter.new ConsumerMq(consumer)).start();
        new Thread(testMProducter.new ConsumerMq(consumer)).start();
        new Thread(testMProducter.new ConsumerMq(consumer)).start();
        new Thread(testMProducter.new ConsumerMq(consumer)).start();
        new Thread(testMProducter.new ConsumerMq(consumer)).start();

    }

    private class ConsumerMq implements Runnable {
        Consumer consumer;

        public ConsumerMq(Consumer cosum) {
            this.consumer = cosum;
        }

        @Override
        public void run() {
            while (true) {
                consumer.getMessage("pengganyu");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}


```

### 监控台

-   127.0.0.1:8161/admin
-   跑一会生产消息后，控制台的QUEU里面会有消息的数量在增加
-   关掉生产消息进程，此时的消息会被存放，等消费消息的代码跑起来后，消息数量才会减少（跑到这里，我激动了一把，这玩意太牛叉了，我以后要好好研究这玩意是怎么实现的）

一些资源
========

-   [ActiveMQ技术详解专栏](http://activemq.apache.org/version-5-getting-started.html)

