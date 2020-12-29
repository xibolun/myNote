---

date :  "2020-07-08T17:44:23+08:00" 
title : "etcd––从源码看lease机制" 
categories : ["etcd"] 
tags : ["etcd"] 
toc : true
description: etcd lease
---

### Lease使用

先声明一个指定过期时间`ttl`的`lease`，再将`lease`绑定到一个`key`上面，`ttl`到期后将`key`移除，这中间有哪些操作呢？

### Lease构成

#### lessor

`lessor`是一个接口，实现了对`lease`的`grant`、`revoke`、`attach`等一系列的操作；在`server.go NewServer`的时候，会新建一个`lessor`

```go
	// always recover lessor before kv. When we recover the mvcc.KV it will reattach keys to its leases.
	// If we recover mvcc.KV first, it will attach the keys to the wrong lessor before it recovers.
	srv.lessor = lease.NewLessor(
		srv.getLogger(),
    // 这个be是一个后端的backend，可以认为是存储操作，是内存或者boltdb
		srv.be,
		lease.LessorConfig{
			MinLeaseTTL:                int64(math.Ceil(minTTL.Seconds())),
			CheckpointInterval:         cfg.LeaseCheckpointInterval,
			ExpiredLeasesRetryInterval: srv.Cfg.ReqTimeout(),
		})
```

#### lease queue

租约队列，实现了`go heap`的接口，有`pop`、`push`、`swap`、`len`操作，本质上是一个数组 `[]*LeaseWithTime`，其构成如下

- `id`:leaseId，由系统生成，`int64`
- `time`：即`ttl（Time To Live）`，还有多久过期
- `index`：在`queue`当中的序号，当队列重新排队的时候，会被修改

```go
type LeaseWithTime struct {
   id LeaseID
   // Unix nanos timestamp.
   time  int64
   index int
}
```

#### LeaseExpiredNotifier

这是一个对象，包含`lease queue`和一个`map`，这个`map`是`leaseId: LeaseWithTime`，方便进行索引

### 实现过程

#### grant

- 创建一个`lease`对象
- 组装`LeaseWithTime`
- 将其放入`queue`当中，在lease queue当中实现对元素的push和重排序操作
  - 为什么会有重排序？因为有可能添加了续约的时间，这个时间time被更新了
- 落盘，根据创建时的`backend`进行持久化操作

```go
func (le *lessor) Grant(id LeaseID, ttl int64) (*Lease, error) {
  ......
	le.leaseMap[id] = l
	item := &LeaseWithTime{id: l.ID, time: l.expiry.UnixNano()}
	le.leaseExpiredNotifier.RegisterOrUpdate(item)
	l.persistTo(le.b)
  .....
}
```

#### ttl处理

- 在`leasor`启动的时候，早早地创建好了`loop`，对`queue`里面的元素进行监听

```go
func (le *lessor) runLoop() {
	defer close(le.doneC)

	for {
		le.revokeExpiredLeases()
		le.checkpointScheduledLeases()

		select {
		case <-time.After(500 * time.Millisecond):
		case <-le.stopC:
			return
		}
	}
}
```

- 每500ms对`lease queue`进行一次`revoke expired lease`操作，这个逻辑也比较简单
  - 查看`lease queue`里面是否存在过期的`lease`，其实就是取第一个，因为每次写入操作都会对队列进行排序，所以第一个就是快过期的；
  - 判断时间是否过期，若过期，则将其从`lease queue`当中`pop`掉

