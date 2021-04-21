---
date :  "2019-10-01T22:52:32+08:00" 
title : "Go源码分析(六)GC" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true
---

### GC的方式

[理解垃圾回收算法](https://www.infoq.cn/article/2017/03/garbage-collection-algorithm) 一文里面有`gif`的形式，直观地描述了常用的`gc`算法

#### 引用计数

- 不足的地方，每次都要对对象进行计数，开销比较大
- 会导致循环引用；A引用了B，B也引用了A，那此时就无法进行gc
- 并且会造成大量的碎片

#### 标记清除

- 标记清除每次都需要`STW`，是对整个内存进行清除，所以性能不是很好

#### 三色标记

- 三色指
  - 白色：无引用（可以被清除的对象）
  - 黑色：当前对象及子对象都存在引用，被标记（一定不会被清理的对象）
  - 灰色：子对象未被标记（本次不确定，下一次再判断一次，是黑还是白）
- 三色标记的问题在于如果确定一个对象是灰色，若gc刚走完，此时已经被标记为白色的对象，添加了一个引用，此时就会错误地gc掉，同时gc的标记也是全局的，最早的版本是没有优化，导致性能很差；优化后，标记与运行态是同时进行的，不影响代码逻辑；
- 那如何解决上面的实时地判断被标记为白色的对象，突然有了一个引用呢？就需要引用到写屏障

#### 写屏障(write Barrier)

- 





### GC触发条件

- gcTriggerAlways: 强制触发GC
- gcTriggerHeap: 当前分配的内存达到一定值就触发GC
- gcTriggerTime: 当一定时间没有执行过GC就触发GC
- gcTriggerCycle: 要求启动新一轮的GC, 已启动则跳过, 手动触发GC的`runtime.GC()`会使用这个条件

### 函数入口

```
// src/runtime/mgc.go method gcStart
func gcStart(mode gcMode, trigger gcTrigger) {
}
```

### 参考

- [*hybrid write barrier* ](https://github.com/golang/proposal/blob/master/design/17503-eliminate-rescan.md)
- [Go垃圾回收 1：历史和原理](http://lessisbetter.site/2019/10/20/go-gc-1-history-and-priciple/)
- 

