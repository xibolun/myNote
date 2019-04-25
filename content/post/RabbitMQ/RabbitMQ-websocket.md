+++
date = "2019-04-25T10:43:27+08:00" title = "RabbitMQ-Websocket" categories = ["技术文章"] tags = ["rabbitmq"] toc = true

+++

### Demo

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Page Title</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>  
    <script src="http://cdn.jsdelivr.net/sockjs/1.0.1/sockjs.min.js"></script>  
    <script src="stomp.js"></script>  
    <script>
        WebSocketStompMock = SockJS;

        var client = Stomp.client('ws://localhost:15674/ws');
        
        function on_connect() {
            client.subscribe("/queue/default", function(data) {
                var msg = data.body;
                alert("收到数据：" + msg);
            })
        };
        function on_error() {
            console.log('error')
        };

        client.connect('guest','guest',on_connect,on_error,'/');
    </script>
</head>
<body>
    <h2>This is RabbitMQ Web STOMP Test</h2>
    <h2>Please see message in console</h2>
</body>
</html>

```

[Stomp.js](https://raw.githubusercontent.com/jmesnil/stomp-websocket/master/lib/stomp.js)是核心文件，将文件内容保存至stomp.js，引入html，启动本地的RabiitMQ即可开始发送和接收消息