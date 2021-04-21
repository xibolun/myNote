---
date :  "2019-08-28T09:53:42+08:00" 
title : "关于Go并发的测验" 
categories : ["技术文章","go"] 
tags : ["go"] 
toc : true
---

### 原由：

今天早上看到鸟窝的一篇blog [Go并发编程小测验： 你能答对几道题？](https://colobu.com/2019/04/28/go-concurrency-quizzes/) 尝试着做了一下，觉得里面有一些还是比较有意思，所以拿出来分析一下。

## 1 Mutex

```go
var mu sync.Mutex
var chain string

func main() {
	chain = "main"
	A()
	fmt.Println(chain)
}
func A() {
	mu.Lock()
	defer mu.Unlock()
	chain = chain + " --> A"
	B()
}
func B() {
	chain = chain + " --> B"
	C()
}
func C() {
	// func A里面的lock未释放，此处会报deadlock
	mu.Lock()
	defer mu.Unlock()
	chain = chain + " --> C"
}
```

## 2 RWMutex

```go
var mu sync.RWMutex
var count int

func main() {
	go A()
	time.Sleep(2 * time.Second)
	mu.Lock()
	defer mu.Unlock()
	count++
	fmt.Println(count)
}
func A() {
	mu.RLock()
	defer mu.RUnlock()
	B()
}
func B() {
	time.Sleep(5 * time.Second)
	C()
}
func C() {
	// 同理mu.RLock未unlock，再次lock时报deadlock
	mu.RLock()
	defer mu.RUnlock()
}
```

## 3 Waitgroup

```go
// panic: sync: WaitGroup is reused before previous Wait has returned
func main() {
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		time.Sleep(time.Millisecond)
		wg.Done()
		wg.Add(1)
	}()
	// 前面goroutine的wg没有done，导致此wait发生异常
	wg.Wait()
}
```

## 4 双检查实现单例

```go

type Once struct {
	m    sync.Mutex
	done uint32
}

func (o *Once) Do(f func()) {
	// 此处线程不安全，可能其他的goroutine读取到的不是1
	if o.done == 1 {
		return
	}
	o.m.Lock()
	defer o.m.Unlock()
	if o.done == 0 {
		o.done = 1
		f()
	}
}

func main() {
	once := &Once{}
	for i := 0; i < 10; i++ {
		once.Do(func() {
			fmt.Println("aa")
		})
	}
}
```

## 5 Mutex

```go
type MyMutex struct {
	count int
	sync.Mutex
}

func main() {
	var mu MyMutex
	mu.Lock()
	var mu2 = mu
	mu.count++
	mu.Unlock()
	// 此时mu2的lock处于lock状态
	// fatal error: all goroutines are asleep - deadlock!
	mu2.Lock()
	mu2.count++
	mu2.Unlock()
	fmt.Println(mu.count, mu2.count)
}

```

## 6 Pool

- TODO 由于对pool和runtime的MemStats不太熟悉，所以先放一下

## 7 channel

```go
// 休眠1s，保证先执行此（channel 1）先会被创建
// 同时time.Tick返回的也是一个通道
//channel 1
//#goroutines: 2
//channel 2
//
func Channel1() {
	var ch chan int
	go func() {
		ch = make(chan int, 1)
		fmt.Println("channel 1")
		ch <- 1
	}()

	go func(ch chan int) {
		time.Sleep(time.Second)
		fmt.Println("channel 2")
		<-ch
	}(ch)
	c := time.Tick(1 * time.Second)
	for range c {
		fmt.Printf("#goroutines: %d\n", runtime.NumGoroutine())
	}
}

// 休眠1s，保证先执行此（channel 1）先会被创建，由于创建的是一个没有缓冲的通道，所以ch的值需要被立马消费
// 同时time.Tick返回的也是一个通道
//channel 1
//channel 2
//#goroutines: 3
func Channel2() {
	var ch chan int
	go func() {
		ch = make(chan int)
		fmt.Println("channel 1")
		ch <- 1
	}()

	go func(ch chan int) {
		time.Sleep(time.Second)
		fmt.Println("channel 2")
		<-ch
	}(ch)
	c := time.Tick(1 * time.Second)
	for range c {
		fmt.Printf("#goroutines: %d\n", runtime.NumGoroutine())
	}
}
func main() {
	//Channel1()
	Channel2()
}

```

## 8 channel

```go
// panic: close of nil channel
func main() {
	var ch chan int
	var count int
	go func() {
		fmt.Println("channel1")
		ch <- 1
	}()

  // 若注释掉此goroutine，会发生deadlock； <-ch在同一goroutine当中进行操作的缘故
	go func() {
    // ch未被初始化，所以是nil
		count++
		close(ch)
	}()

	<-ch

	fmt.Println(count)
}

// ------------------------------------------

// 输出0
func main() {
	var ch chan int
	var count int
	go func() {
		fmt.Println("channel1")
		ch <- 1
	}()

	go func() {
     // 若把 <-ch放在这里，就可以正常跑下去，因为channel通道在两个协程之间已经通信
		<-ch
		count++
		close(ch)
	}()

	fmt.Println(count)
}

```

## 9 Map

并发Map没有长度

## 10 happens before

由于通道的特性，会阻塞一直等到有数据写入

## 11 自定义Map

```
// length并没有添加锁
func (m *Map) Len() int {
	return len(m.m)
}
```

## 12 slice

由于两个goroutine都在执行，会有重叠的的部分，所以值的区间是[1000,2000]

## 13 goroutine

对比一下下面两个test函数，应该就明白为什么一直输出`9999999999`
```go

func TestGoRoutine(t *testing.T) {
	var wg sync.WaitGroup
	wg.Add(10)
	var ts = make([]T, 10)
	for i := 0; i < 10; i++ {
		ts[i] = T{i}
	}
	for _, t := range ts {
		go t.Incr(&wg)
	}
	wg.Wait()
	for _, t := range ts {
		fmt.Println(t)
		go t.Print()
	}
	time.Sleep(5 * time.Second)
}

// 将ts数组里面的变为指针变量
func TestGoRoutine2(t *testing.T) {
	var wg sync.WaitGroup
	wg.Add(10)
	var ts = make([]*T, 10)
	for i := 0; i < 10; i++ {
		ts[i] = &T{i}
	}
	for _, t := range ts {
		go t.Incr(&wg)
	}
	wg.Wait()
	for _, t := range ts {
		fmt.Println(t)
		go t.Print()
	}
	time.Sleep(5 * time.Second)
}

```

或者修改`Print`函数也可

```go
func (t *T) Print() {
	time.Sleep(1e9)
	fmt.Print(t.V)
}

func (t T) Print() {
	time.Sleep(1e9)
	fmt.Print(t.V)
}
```

