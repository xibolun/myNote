---

date :  "2019-03-18T17:26:28+08:00" 
title : "Go—RPC" 
categories : ["技术文章","go"] 
tags : ["go"] 
toc : true

---

### 什么是RPC

- Remote Procedure Call，远程调用另外一台服务器上面的一个函数；
- 是一种协议，Rest API，Web Service都属于RPC

### RPC架构

- sever端
  - Listener
  - ServerNames、Method
  - Register
- customer端
  - Conn
  - Call

### 示例

```
package rpc

type HelloService struct{}

func (p *HelloService) Hello(request string, replay *string) error {
	*replay = "hello" + request
	return nil
}

```

Server

```
package rpc

import (
	"log"
	"net"
	"net/rpc"
	"testing"
)

func TestServerStart(t *testing.T) {
	_ = rpc.RegisterName("HelloService", new(HelloService))

	listener, err := net.Listen("tcp", ":1234")
	if err != nil {
		log.Fatal(err)
	}

	conn, err := listener.Accept()
	if err != nil {
		log.Fatal(err)
	}

	rpc.ServeConn(conn)
}

```

Customer

```
package rpc

import (
	"fmt"
	"net/rpc"
	"testing"
)

func TestCustomer(t *testing.T) {
	client, err := rpc.Dial("tcp4", ":1234")

	if err != nil {
		t.Error(err)
	}

	var replay string
	if err := client.Call("HelloService.Hello", " world", &replay); err != nil {
		t.Error(err)
	}

	fmt.Println(replay)
}

```

### 说明

- go里面的rpc函数方法必须是两个入参，第二个入参是指针对象，返回一个error；这是由于go内置的rpc实现