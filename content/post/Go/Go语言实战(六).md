---
date :  "2019-08-07T09:03:50+08:00" 
title : "Go语言实战(六)并发" 
categories : ["技术文章"] 
tags : ["go"] 
toc : false
---

## Go语言实战(六)并发

### 线程与进程

- 应用启动的时候就会有一个进程(Process)，像linux里面的PID；一个进程可以起多个Thread(线程)；所以一个进程至少包含一个线程，进程终止，那线程也就game over

### 并发与并行

- 并发(concurrency)是多个线程一起跑，而并行(Parallelism)是跑在不同的处理器上面，依赖于cpu的核心，若是单核的，那就不用谈什么并行了；而并发却可以跑在单核的CPU上

### goroutine

- 如何启动一个goroutine? 使用关键字go就可以了

```
	// channel stop then main routine util write data
	go greet(c)
```

- channel自带阻塞功能，读是一个等待的过程

```go
func greet(c chan string) {
	fmt.Printf("hello +%s\n", <-c)
}

func TestChannel1(t *testing.T) {
	c := make(chan string)

	// channel stop then main routine util write data
	greet(c)

	fmt.Printf("after greet")
}

func TestChannel2(t *testing.T) {
	c := make(chan string)

	// channel stop then main routine util write data
	go greet(c)

	c <- "world"
	fmt.Printf("after greet")
}
输出：
hello +world
after greet
```

- deadlock

```go
package main

import "fmt"

func main() {
	fmt.Println("main() started")

	c := make(chan string)
	c <- "John"
	
	fmt.Println("main() stopped")
}
```

### 关于waitgroup的11个测试

[waitgroup_test](https://github.com/kedadiannao220/GOTest/blob/master/waitgroup_test.go)

### 竞争

```go
/**
竞争, 多个线程争抢一个资源，无法保证资源的原子性
*/
func TestCompete(t *testing.T) {
	var count int32
	var wg sync.WaitGroup

	threadNum := 2
	wg.Add(threadNum)

	for i := 0; i < threadNum; i++ {
		go incCount(&wg, &count)
	}

	wg.Wait()
	fmt.Println(count)
}

func incCount(wg *sync.WaitGroup, count *int32) {
	defer wg.Done()
	for i := 0; i < 2; i++ {
		value := *count
		runtime.Gosched()
		value++
		*count = value
	}

}
```

由于多个线程一起跑，所以count处于一个竞争状态，即线程不安全，输出的结果也就不确定，可能是2、3、4

### 使用Atomic进行操作

```go

/**
使用原子操作，进行处理，使得资源能够保证线程安全
*/

func TestCompeteAtomic(t *testing.T) {
	t.Parallel()

	t.Run("competeAtomicTest", func(t *testing.T) {
		CompeteAtomicFunc()
	})
}

func CompeteAtomicFunc() {
	var (
		count int64
		wg    sync.WaitGroup
	)

	threadNum := 2
	wg.Add(threadNum)

	for i := 0; i < threadNum; i++ {
		go incAtomicCount(&wg, &count)
	}
	wg.Wait()

	fmt.Println(count)
}

func incAtomicCount(wg *sync.WaitGroup, count *int64) {
	defer wg.Done()
	for i := 0; i < 2; i++ {
		atomic.AddInt64(count, 1)
	}
}
```

原子操作能够保证输出结果一直都是4

### 互斥锁

可以使用go自带的mutex进行操作；当修改资源的时候先进行锁住，修改完成再释放掉

```go

/**
	使用互斥锁操作，进行处理，使得资源能够保证线程安全
*/

func TestCompeteMutex(t *testing.T) {
	t.Parallel()

	t.Run("competeMutexTest", func(t *testing.T) {
		CompeteMutexFunc()
	})
}

func CompeteMutexFunc() {
	var (
		count int64
		wg    sync.WaitGroup
		mu    sync.Mutex
	)

	threadNum := 3
	wg.Add(threadNum)

	for i := 0; i < threadNum; i++ {
		go incMutexCount(&wg, &mu, &count)
	}
	wg.Wait()

	fmt.Println(count)
}

func incMutexCount(wg *sync.WaitGroup, mu *sync.Mutex, count *int64) {
	defer wg.Done()
	for i := 0; i < 2; i++ {
		mu.Lock()
		{
			value := *count
			value++
			*count = value
		}
		mu.Unlock()
	}
}
```

### 通道

 多个goroutine之间建立起通道，就可以进行数据的传输；通道的数据类型可以是基础数据类型，结构体，引用类型或指针；通道分为有缓冲通道、无缓冲通道；

```go
c := make(chan string) // 无缓冲通道
c := make(chan string 10) //有缓冲通道
close(c)  //关闭通道
```

#### 通道的长度和容量

有缓冲的通道的容量是初始的时候设定的；若超出容量，则会挂起，等待被消费

```go
// TestResult
//		=== RUN   TestChannel3
//		c1 length: 0, capacity: 0
//		c2 length: 0, capacity: 10
//		c2 length: 10, capacity: 10
//		c2 holding, not run
func TestChannel3(t *testing.T) {
	c1 := make(chan int)
	c2 := make(chan int, 10)
	fmt.Printf("c1 length: %d, capacity: %d\n", len(c1), cap(c1))
	fmt.Printf("c2 length: %d, capacity: %d\n", len(c2), cap(c2))

	for i := 0; i < 10; i++ {
		c2 <- i
	}
	fmt.Printf("c2 length: %d, capacity: %d\n", len(c2), cap(c2))

	// 超出c2的capacity的时候，routine会等待被取走数据后再写入
	fmt.Printf("c2 holding, not run\n")
	c2 <- 11
}
```

#### 通道是有序的，先进先出

```go
// TestResult
//		value of c2 is: 0
//		value of c2 is: 1
//		value of c2 is: 2
//		value of c2 is: 3
//		value of c2 is: 4
//		value of c2 is: 5
//		value of c2 is: 6
//		value of c2 is: 7
//		value of c2 is: 8
//		value of c2 is: 9
func TestChannel4(t *testing.T) {
	c2 := make(chan int, 10)
	for i := 0; i < 10; i++ {
		c2 <- i
	}

	for i := 0; i < 10; i++ {
		fmt.Printf("value of c2 is: %d\n", <-c2)
	}
}

```

