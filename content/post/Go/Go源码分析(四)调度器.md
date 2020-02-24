---
date :  "2019-09-10T22:52:32+08:00" 
title : "Go源码分析(四)调度器" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### 调度器

在高并发场景当中，一般会起很多的协程(goroutine)，这样一来，就会导致阻塞操作；为了解决这些问题，go语言自己实现了一套 [调度器](https://docs.google.com/document/d/1TTj4T2JO42uD5ID9e89oa0sLKhJYD0Y_kqxDv3I3XMw/edit)，用于调度多个goroutine的执行，协程相对于线程来说很轻量，生命周期非常短暂，速度很快；所以这也就是为什么golang的执行速度非常的快的原因；

那怎么样来调度呢？简单来讲就是将当前cpu核心所持有的协程给其他的cpu执行，怎么给，什么时候给呢？那就需要理解一下P、G、M、sched；

golang在 `src/runtime/runtime2.go`文件当中有四个结构体类型，通过这四个结构体完成了整个调度器的建模

- shced：golang的调度器
- G：即goroutine
- M：操作系统线程
- P：类似CPU的核心数

### sched

初始化调度器`src/runtime/proc.go`

```go
// The bootstrap sequence is:
//
//	call osinit
//	call schedinit
//	make & queue new G
//	call runtime·mstart
//
// The new G calls runtime·main.
func schedinit() {
	// raceinit must be the first call to race detector.
	// In particular, it must be done before mallocinit below calls racemapshadow.
	// G的初始化
	_g_ := getg()
	if raceenabled {
		_g_.racectx, raceprocctx0 = raceinit()
	}

	sched.maxmcount = 10000
	
	// M的初始化
	mcommoninit(_g_.m)
	// cpu初始化
	cpuinit()       // must run before alginit
	.......
	// P的初始化
	procs := ncpu
	if n, ok := atoi32(gogetenv("GOMAXPROCS")); ok && n > 0 {
		procs = n
	}
	......
}
```

看到调度器初始化的时候会将P、G、M进行初始化；

### P

结构体定义

```go
// src/runtime/runtime2.go
type p struct {
	id          int32
	status      uint32 // P的状态，pidle、prunning、pgcstop、psyscall
	......
	mcache      *mcache
	raceprocctx uintptr

	// PPool
	deferpool    [5][]*_defer // pool of available defer structs of different sizes (see panic.go)
	deferpoolbuf [5][32]*_defer

	// Cache of goroutine ids, amortizes accesses to runtime·sched.goidgen.
	goidcache    uint64
	goidcacheend uint64

	// Queue of runnable goroutines. Accessed without lock.
	runqhead uint32
	runqtail uint32
	runq     [256]guintptr
	// runnext, if non-nil, is a runnable G that was ready'd by
	// the current G and should be run next instead of what's in
	// runq if there's time remaining in the running G's time
	// slice. It will inherit the time left in the current time
	// slice. If a set of goroutines is locked in a
	// communicate-and-wait pattern, this schedules that set as a
	// unit and eliminates the (potentially large) scheduling
	// latency that otherwise arises from adding the ready'd
	// goroutines to the end of the run queue.
	runnext guintptr

	// Available G's (status == Gdead)
	gFree struct {
		gList
		n int32
	}
	......
}

```

#### P的生命周期(状态)

- 新建的时候是`_Pgcstop`

```go
// src/runtime/proc.go
// init initializes pp, which may be a freshly allocated p or a
// previously destroyed p, and transitions it to status _Pgcstop.
func (pp *p) init(id int32) {
	pp.id = id
	pp.status = _Pgcstop
	......
}
```

- 初始化完成后，如果有M在运行，则P的状态为`_Prunning`

```go
// src/runtime/proc.go  method procresize 
if _g_.m.p != 0 && _g_.m.p.ptr().id < nprocs {
		// continue to use the current P
		_g_.m.p.ptr().status = _Prunning
		_g_.m.p.ptr().mcache.prepareForSweep()
	} else {
   	.......
		p.status = _Pidle
		......
	}
```

- 上面代码当中可以看到若没有M在运行，那P的状态就置为`_Pidle`；在`acquirep`的函数实现里面，会将p的状态从`_Prunning`-> `_Pidle`

```go
// src/runtime/proc.go  method acquirep
func acquirep(_p_ *p) {
	// Do the part that isn't allowed to have write barriers.
	wirep(_p_)
	.....
}
func wirep(_p_ *p) {
	......
	_p_.status = _Prunning
}
```

- 通过`releasep`，将P的状态从`_Prunning`--> `_Pidle`

```go
// src/runtime/proc.go  method releasep 
func releasep() *p {
	......
	_p_.status = _Pidle
	return _p_
}
```

- `_Prunning`可以与`_Psyscall`状态进行切换

```go
// 通过entersyscall P由_Prunning变为_Psyscall
func entersyscall() {
	reentersyscall(getcallerpc(), getcallersp())
}

// 通过exitsyscall --> exitsyscallfast --> wirep; P由_Psyscall变为_Prunning
func exitsyscall() {
	......
	exitsyscallfast
	.....
}
//go:nosplit
func exitsyscallfast(oldp *p) bool {
......
// Try to re-acquire the last P.
	if oldp != nil && oldp.status == _Psyscall && atomic.Cas(&oldp.status, _Psyscall, _Pidle) {
		// There's a cpu for us, so we can run.
		wirep(oldp)
		exitsyscallfast_reacquired()
		return true
	}
}
func wirep(_p_ *p) {
	......
	_p_.status = _Prunning
}
```

- 而`destory`是将P状态变为`_Pdead`

```go
// src/runtime/proc.go  method destroy 
func (pp *p) destroy() {
	......
	pp.status = _Pdead
}

```

那什么时候会执行`destory`方法呢？前置调用`procresize`的时候，(可以是设置`GOMAXPROCS`参数)若发生减少P的情况，即会销毁P

```go
	// src/runtime/proc.go  method procresize当中有一处 
	// release resources from unused P's
	for i := nprocs; i < old; i++ {
		p := allp[i]
		p.destroy()
		// can't free P itself because it can be referenced by an M in syscall
	}
```

### M

结构体定义

```go
// src/runtime/runtime2.go
type m struct {
	g0      *g     // goroutine with scheduling stack
	morebuf gobuf  // gobuf arg to morestack
	divmod  uint32 // div/mod denominator for arm - known to liblink

	// Fields not known to debuggers.
	procid        uint64       // for debuggers, but offset not hard-coded
	gsignal       *g           // signal-handling g
	goSigStack    gsignalStack // Go-allocated signal handling stack
	sigmask       sigset       // storage for saved signal mask
	tls           [6]uintptr   // thread-local storage (for x86 extern register)
	mstartfn      func()
	curg          *g       // current running goroutine
	caughtsig     guintptr // goroutine running during fatal signal
	p             puintptr // attached p for executing go code (nil if not executing go code)
......
	spinning      bool // m is out of work and is actively looking for work
......
	alllink       *m // on allm
	schedlink     muintptr
}
```

由上面可以看出

- 一个M需要绑定一个P才会去执行，结构体里面有一个p的字段地址，如果没有执行则为nil
- 一个M会绑定一个goroutine，即`curg`，保存着当前`running goroutine`的指针对象
- M去执行goroutine的时候也需要用一个goroutine，即`g0`
- 其他后续再补充......
- ......

#### M的状态

- 持有G，就是执行(非自旋)

```go
func mspinning() {
	// startm's caller incremented nmspinning. Set the new M's spinning.
	getg().m.spinning = true
}
//go:nowritebarrierrec
func startm(_p_ *p, spinning bool) {}
```

- 不持有G，就是等待(自旋)，此种状态的好处就是省去创建M的开销；

```go
// Stops execution of the current m until new work is available.
// Returns with acquired P.
func stopm() {......}
```

### G

我们会聊一个问题，goroutine与thread[有什么区别呢](https://blog.nindalf.com/posts/how-goroutines-work/)？可以参考 [go-nuts](https://groups.google.com/forum/#!topic/golang-nuts/j51G7ieoKh4)里面的讨论

- 从内存占用上来说：一个goroutine初始化`stack`大小为2kb，而一个线程为1MB；这样会更加小的开支
- 从创建和销毀来说：创建一个线程 需要使用cpu的调度，需要与硬件打交道，但是呢创建一个goroutine不需要，因为初始化runtime的时候线程已经创建好了，而创建的goroutine会依附的M上面去执行；
- 从切换来讲：线程切换需要将executing的线程先放到暂存器里面，然后将runnable的线程拿过来执行；goroutine也是这样做，但是暂存器只有三种，但goroutine的切的时间远远小于线程切换时间1000-1500 纳秒，只需要 200 ns

如何创建？

`src/runtime/proc.go`

```go
// Create a new g running fn with siz bytes of arguments.
// Put it on the queue of g's waiting to run.
// The compiler turns a go statement into a call to this.
// Cannot split the stack because it assumes that the arguments
// are available sequentially after &fn; they would not be
// copied if a stack split occurred.
//go:nosplit
func newproc(siz int32, fn *funcval) {
	argp := add(unsafe.Pointer(&fn), sys.PtrSize)
	gp := getg()
	pc := getcallerpc()
	systemstack(func() {
		newproc1(fn, (*uint8)(argp), siz, gp, pc)
	})
}
```

### 调度原理

#### 先得有G，才能干活

首先了解一下`LRQ`本地可运行队列(LocalRunningQueue)、`GRQ`全局可运行队列(GlobalRunningQueue)

```go
// GRQ
type schedt struct{
	....
		// 全局的G队列
    runq     gQueue
		runqsize int32
	....
}

```

```go
// LRQ
type p struct{
	// Queue of runnable goroutines. Accessed without lock.
	runqhead uint32
	runqtail uint32
	runq     [256]guintptr
}

```

- A：初始化的时候先去全局里面看看有没有，`func globrunqget(_p_ *p, max int32) *g {...}`
  - 如果有，放到本地的p队列里面，
  - 如果没有，那就看本地的队列里面有没有`func runqget(_p_ *p) (gp *g, inheritTime bool) {...}`
    - C：如果有，那么去执行
    - 如果没有，去看`poll`网络里面有idle
      - 如果有，则C
      - 如果没有，去其他P里面去偷 
- B：本地队列执行完了怎么办？
  - 再去看看全局里面有没有，即重复执行上面的`A`
- 具体如何找一个G，在函数``func findrunnable() (gp *g, inheritTime bool) {...}`里面

#### 有了G，便得有M

如果有了G，如果g绑定的M处于自旋状态，则进行`wakeup`操作

```
	if _g_.m.spinning {
		resetspinning()
	}
```

#### 有了M，再有一个P就可以干活了

如果G里面的P不是nil，则就可以直接干活，如果没有，那需要`wakeP`，`tryWakeP`就是在上面进行判断`g`的`p`是否正常

```go
	// If about to schedule a not-normal goroutine (a GCworker or tracereader),
	// wake a P if there is one.
	if tryWakeP {
		if atomic.Load(&sched.npidle) != 0 && atomic.Load(&sched.nmspinning) == 0 {
			wakep()
		}
	}
```

#### 怎么干活？

```go
	execute(gp, inheritTime)
```

大概步骤：

- 切换`g`的状态`_Grunnable`––> `_Grunning`

```go
	casgstatus(gp, _Grunnable, _Grunning)
```

- 将`gp`绑定到M，同时`gp`里面M也给绑定；即执行的`_g_`与需要执行的`gp`都绑定上M

```go
	_g_.m.curg = gp
	gp.m = _g_.m
```

- 然后进行`gogo`

```assembly
	gogo(&gp.sched)

// src/runtime/asm_amd64.s
// func gogo(buf *gobuf)
// restore state from Gobuf; longjmp
TEXT runtime·gogo(SB), NOSPLIT, $16-8
	MOVQ	buf+0(FP), BX		// gobuf
	MOVQ	gobuf_g(BX), DX
	MOVQ	0(DX), CX		// make sure g != nil
	get_tls(CX)
	MOVQ	DX, g(CX)
	MOVQ	gobuf_sp(BX), SP	// restore SP；这个SP像一个勾子一样，执行完之后回到schedule当中
	MOVQ	gobuf_ret(BX), AX
	MOVQ	gobuf_ctxt(BX), DX
	MOVQ	gobuf_bp(BX), BP
	MOVQ	$0, gobuf_sp(BX)	// clear to help garbage collector
	MOVQ	$0, gobuf_ret(BX)
	MOVQ	$0, gobuf_ctxt(BX)
	MOVQ	$0, gobuf_bp(BX)
	MOVQ	gobuf_pc(BX), BX
	JMP	BX
```

- 最后执行`goexit1`，而`goexit1`最终调用的是`goexit0`

```assembly
/ 在 goroutine 返回 goexit + PCQuantum 时运行的最顶层函数。
TEXT runtime·goexit(SB),NOSPLIT,$0-0
	BYTE	$0x90	// NOP
	CALL	runtime·goexit1(SB)	// 不会返回
	// traceback from goexit1 must hit code range of goexit
	BYTE	$0x90	// NOP
```

```go
// Finishes execution of the current goroutine.
func goexit1() {
	if raceenabled {
		racegoend()
	}
	if trace.enabled {
		traceGoEnd()
	}
	// 这里调用goexit0
	mcall(goexit0)
}
```

```go
// goexit continuation on g0.
func goexit0(gp *g) {
	_g_ := getg()
	.......
	schedule()
}
```

- 执行`goexit0`里面的大概逻辑

```go
// goexit continuation on g0.
func goexit0(gp *g) {
	_g_ := getg()

	// 切换gp的状态，从running变为dead
	casgstatus(gp, _Grunning, _Gdead)
	......
	// 解绑M
	gp.m = nil
	locked := gp.lockedm != 0
	gp.lockedm = 0
	// 清空_g_.m里面的持有g
	_g_.m.lockedg = 0
	gp.paniconfault = false
	// 将各种变更都置为nil
	gp._defer = nil // should be true already but just in case.
	gp._panic = nil // non-nil for Goexit during panic. points at stack-allocated data.
	gp.writebuf = nil
	gp.waitreason = 0
	gp.param = nil
	gp.labels = nil
	gp.timer = nil

	// Note that gp's stack scan is now "valid" because it has no
	// stack.
	gp.gcscanvalid = true
	// 丢弃g
	dropg()

  // 处理p里面的g队列
	gfput(_g_.m.p.ptr(), gp)
	.....
	// 再次开始调度
	schedule()
}

```

以上为自己的学习笔记，可能会有错误或者理解不到位的地方，参考资料里面写的有很多；

### 参考资料

- [深度解密Go语言之scheduler](https://qcrao.com/2019/09/02/dive-into-go-scheduler/)
- [go-runtime-scheduler](https://speakerdeck.com/retervision/go-runtime-scheduler)
- [Analysis of the Go runtime scheduler](http://www.cs.columbia.edu/~aho/cs6998/reports/12-12-11_DeshpandeSponslerWeiss_GO.pdf)
- [《Go Under The Hoold》–– 调度循环](https://changkun.de/golang/zh-cn/part2runtime/ch06sched/exec/)

