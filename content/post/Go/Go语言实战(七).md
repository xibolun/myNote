---
date :  "2019-05-23T11:41:46+08:00" 
title : "Go语言实战(七)并发模式" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

## Go语言实战(七)并发模式

### runner

```go
type Runner struct {
	interrupt chan os.Signal   // 任务中断
	timeout   <-chan time.Time // 单向通道，只能接收，不能写入
	complete  chan error       // 任务结束，有可能返回error
	tasks     []func(int)      // 需要执行的任务列表
}

var (
	ErrTimeout   = errors.New("received timeout")
	ErrInterrupt = errors.New("received interrupt")
)
```

- tasks设计为数组函数，是一个非常优雅的地方，这样需要执行的逻辑可以放到task函数里面实现
- timeout是一个单向的通道，只能写入，即runner初始化的时候已经指定好了超时时间，无法再次修改
- signal是什么，作用是什么？ golang的 [signal](https://golang.org/pkg/os/signal/) ; [unix-signal](https://www.tutorialspoint.com/unix/unix-signals-traps.htm) 操作系统层面的一些信号标识
- 先声明错误，这样效率会更高一些

创建runner

```go 
func NewRunner(t time.Duration) *Runner {
	return &Runner{
		timeout:   time.After(t),
		interrupt: make(chan os.Signal, 1),
		complete:  make(chan error),
	}
}
```

有了任务的处理，我们想添加任务怎么做？接收一个tasks列表，将其append到runner里面；注意tasks是一个数组，需要解开。

```go 
func (r *Runner) AddTask(tasks ...func(int)) {
	r.tasks = append(r.tasks, tasks...)
}
```

如何判断任务是否被打断？ 若signal发出来信号，那么会传递到interrupt的通道里面，可以根据runner里面的interrupt通道里面是否存在数据信息来进行处理

```go
func (r *Runner) gotInterrupt() bool {
	select {
	case <-r.interrupt:
		signal.Stop(r.interrupt)
		return true
	default:
		return false
	}
}
```

将任务开启起来，遍历tasks；开始运行，返回对应的错误

```go
func (r *Runner) run() error {
	for i, task := range r.tasks {
		if r.gotInterrupt() {
			return ErrInterrupt
		}
		task(i)
	}
	return nil
}
```

Start任务,主任务

```go
func (r *Runner) Start() error {
  // 接收操作系统interrupt信号； Ctrl+c
	signal.Notify(r.interrupt, os.Interrupt)

	go func() {
		r.complete <- r.run() //将run出来的结果返回给complete
	}()

	select {
	case err := <-r.complete:
		return err
	case <-r.timeout:
		return ErrTimeout
	}
}
```

测试方法

```go
func TestRunner(t *testing.T) {
	r := NewRunner(3 * time.Second)

	r.AddTask(CreateTask(), CreateTask(), CreateTask())

	if err := r.Start(); err != nil {
		switch err {
		case ErrTimeout:
			log.Println("Terminating due to timeout")
			os.Exit(1)
		case ErrInterrupt:
			log.Println("Terminating due to interrupt")
			os.Exit(2)
		}
	}
	log.Println("process done")
}

func CreateTask() func(int) {
	return func(id int) {
		log.Printf("task %d", id)
		time.Sleep(time.Duration(id) * time.Second)
	}
}
```

