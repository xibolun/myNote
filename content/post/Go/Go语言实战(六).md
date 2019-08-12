---
date :  "2019-08-07T09:03:50+08:00" 
title : "Go语言实战(六)并发" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### 

### goroutine

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

函数准备

```go
func WaitGroup(procs, wgAdd, second int) {
	fmt.Printf("test start, procs: %d, wgAdd: %d, second: %d\n", procs, wgAdd, second)
	runtime.GOMAXPROCS(procs)
	var wg sync.WaitGroup
	wg.Add(wgAdd)

	go printPrime("A", &wg)
	go printPrime("B", &wg)

	if second > 0 {
		time.Sleep(time.Duration(second) * time.Second)
	}

	fmt.Println("Waiting To Finish")
	wg.Wait()

	fmt.Println("done")
}

// printPrime print prime
func printPrime(prefix string, wg *sync.WaitGroup) {
	defer (*wg).Done()
next:
	for outer := 2; outer < 5000; outer++ {
		for inner := 2; inner < outer; inner++ {
			if outer%inner == 0 {
				continue next
			}
		}
		fmt.Printf("%s:%d\n", prefix, outer)
	}
	fmt.Println("Completed", prefix)
}
```
#### 测试列表，每个测试的输出是怎样的？

```go
func TestWaitGroup1(t *testing.T) {
	WaitGroup(0, 0, 0)
}

func TestWaitGroup(t *testing.T) {
	WaitGroup(0, 0, 10)
}

func TestWaitGroup2(t *testing.T) {
	WaitGroup(1, 0, 0)
}

func TestWaitGroup3(t *testing.T) {
	WaitGroup(1, 0, 5)
}

func TestWaitGroup4(t *testing.T) {
	WaitGroup(1, 1, 0)
}

func TestWaitGroup5(t *testing.T) {
	WaitGroup(1, 2, 0)
}

func TestWaitGroup6(t *testing.T) {
	WaitGroup(2, 2, 0)
}

func TestWaitGroup7(t *testing.T) {
	WaitGroup(2, 1, 0)
}

func TestWaitGroup8(t *testing.T) {
	WaitGroup(2, 1, 10)
}

func TestWaitGroup9(t *testing.T) {
	WaitGroup(4, 2, 0)
}

func TestWaitGroup10(t *testing.T) {
	WaitGroup(1, 3, 0)
}

func TestWaitGroup11(t *testing.T) {
	WaitGroup(2, 3, 0)
}
```
