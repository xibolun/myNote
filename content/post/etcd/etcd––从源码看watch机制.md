---

date :  "2020-07-07T10:13:54+08:00" 
title : "etcd––从源码看watch机制" 
categories : ["技术文章","etcd"] 
tags : ["etcd"] 
toc : true
description: etcd watch
---

### Watch使用

`watch`有两种操作，一种是`key`，一种是`range`，即监听一段的`key`，从一个测试用例里面看看，主要包括几个操作

- 初始化一个watchablestore
- 初始化watchStream
- 使用watchStream创建一个watch对象，监听一个Key
- 使用put操作进行测试即可完成整个流程

```go
func TestWatch(t *testing.T) {
	b, tmpPath := backend.NewDefaultTmpBackend()
	s := newWatchableStore(zap.NewExample(), b, &lease.FakeLessor{}, nil, StoreConfig{})

	defer func() {
		s.store.Close()
		os.Remove(tmpPath)
	}()

	testKey := []byte("foo")
	testValue := []byte("bar")
	s.Put(testKey, testValue, lease.NoLease)

	w := s.NewWatchStream()
	w.Watch(0, testKey, nil, 0)

	if !s.synced.contains(string(testKey)) {
		// the key must have had an entry in synced
		t.Errorf("existence = false, want true")
	}
}
```

### Watch结构

#### event

监听即为事件信息，对事件进行封装，里面结构如下

- `type`：操作类型，`DELET`、`PUT`
- `KV`：`key\value`
- `PrevKV`：上一版本的`kv`

#### watcher

使用`watch`命令的时候即为使用此对象来存放所监听的key，并负责对事件最终的发送；里面重要结构如下：

- `key`：`key`列表
- `end`：若是监听一段`key`的变化，则会有一个区间形式的操作，[start，end)
- `victim`：翻译为牺牲者，当有事件可以发送时，client可能存在一定的问题未发送成功（比如说通道满了）是否存在未发送成功的事件，是一个标记
- `compacted`：对事件进行压缩
- `fcs`：这是一个函数过滤器列表，过滤出`client`只想监听的`key`
- `ch`：还有一个`watchResponse`，用于将监听的事件发送出去，形成消息通道

#### watcherGroup

`watcher`的集合，正因为这样的设计，所以`etcd`支持一段`key`的`watch`，里面结构如下：

- `keyWatchers`：一个`map`对象，`key`为需要监听的`key`，`value`为`watcherSet`
- `ranges`：红黑树(`adt`)，用于对`key`->`watcher`结构进行快速查询，存储、删除操作
- `watchers`：`watcher`列表

#### watchstream

创建`watchserver`的时候，会创建一个`watchStream`；`stream`里面起了一个`for`循环，会监听`rpc`消息过来的`watch`事件信息：创建`watch`、取消`watch`，处理`watch`；

```go
func (sws *serverWatchStream) recvLoop() error {
	switch uv := req.RequestUnion.(type) {
		case *pb.WatchRequest_CreateRequest:
		case *pb.WatchRequest_CancelRequest:
		case *pb.WatchRequest_ProgressRequest:
}
```

#### watchstore

初始化`server`的时候生成，里面主要包含几个东西

- `store`：对`boltdb`进行封装，实现底层数据的操作
- `victimc`：翻译为牺牲者，实际上是发送给client失败后的一些事件信息
- `unsynced`：本质上是`waitGroup`，未发送给`client`的事件，创建`key`的监听时，监听`key`的`rev`若小于库里面的`rev`存放于此
- `synced`：本质上是`waitGroup`，需要发送给`client`的事件都在此存放

### 工作原理

#### 初始化

- 初始化`server`

- 初始化`mvcc`

- 初始化`watchstore`

  - 启动监听`watcher`循环
  - 启动监听`victims`循环

```go
  	go s.syncWatchersLoop()
  	go s.syncVictimsLoop()
```

#### syncWatchers

- `kvsToEvents`：将变更的`kv`进行`event`化处理，此时会从`watcherGroup`当中是否包含这个`key`，从红黑树里面拿到结果

- 将`key`的rev与`store`的`rev`进行比对，判断此`watch`是否需要进行`sync`，还是放在`unsync`当中
- 组装`watchResponse`，发送至`client`；若发送失败，将`event`放至`victims`里面，走`syncVictimsLoop`逻辑

#### client put&&end

`put`操作最终会进行事务提交，所以最后会走到`mvcc`模块，这里面会有`put`操作

```go
func (tw *storeTxnWrite) put(key, value []byte, leaseID lease.LeaseID) {
......
	tw.trace.Step("marshal mvccpb.KeyValue")
	tw.tx.UnsafeSeqPut(keyBucketName, ibytes, d)
	tw.s.kvindex.Put(key, idxRev)
	tw.changes = append(tw.changes, kv)
	tw.trace.Step("store kv pair into bolt db")
......
}
```

将`kv`的数据信息放至`changes`里面；将`key`与revision信息重新存放至`btree`里面

在`put`完成之后，会有`end`操作

```go
func (wv *writeView) Put(key, value []byte, lease lease.LeaseID) (rev int64) {
	tw := wv.kv.Write(traceutil.TODO())
	defer tw.End()
	return tw.Put(key, value, lease)
}
```

#### watchableStroe  end

`end`函数里面会对`kv`进行`event`化处理，最后`notify`至`watchstream`的`channel`当中

```go
func (tw *watchableStoreTxnWrite) End() {
	changes := tw.Changes()
	if len(changes) == 0 {
		tw.TxnWrite.End()
		return
	}

	rev := tw.Rev() + 1
	evs := make([]mvccpb.Event, len(changes))
	for i, change := range changes {
		evs[i].Kv = &changes[i]
		if change.CreateRevision == 0 {
			evs[i].Type = mvccpb.DELETE
			evs[i].Kv.ModRevision = rev
		} else {
			evs[i].Type = mvccpb.PUT
		}
	}

	tw.s.mu.Lock()
  // notify
	tw.s.notify(rev, evs)
	tw.TxnWrite.End()
	tw.s.mu.Unlock()
}

```

### sendWatchResponse

将`event`的`key`在`watcherGroup`当中查找到对应的`watcher`，然后将数据变更信息发送至`client`

### 参考

- [HammerMax的关于etcd分析的blog，图片画的很不错](https://segmentfault.com/a/1190000021787055)