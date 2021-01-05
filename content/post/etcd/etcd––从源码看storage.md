---

date :  "2020-07-05T14:32:00+08:00" 
title : "etcd––从源码看Storage" 
categories : ["etcd"] 
tags : ["etcd"] 
toc : true
description: etcd storage types
---

当启动了一个`etcd server`的时候，会生成一些数据文件，这些文件便是`etcd storage`，主要分析`wal`和`snapshot`

```shell
➜  tree
.
└── member
    ├── snap
    │   └── db
    └── wal
        ├── 0.tmp
        └── 0000000000000000-0000000000000000.wal
```

### WAL

`WAL`是与磁盘打交道的模块，这个是用于数据持久化的；

#### 存储结构

几个重要的属性

- start： 快照开始读的地方
- decoder、encoder：将`entry`进行序列化和反序列化
- state：wal的头部
- metadata：每个wal的头部信息，记录着`NodeId`、`ClusterID`

```go
// etcdserver/raft.go#startNode
metadata := pbutil.MustMarshal(
		&pb.Metadata{
			NodeID:    uint64(member.ID),
			ClusterID: uint64(cl.ID()),
		},
	)
```

- locks： 文件锁

一个`wal`文件是由多个`record`组成，record的结构如下：

```go
type Record struct {
  // 类型，可以是metadata、entry、state、crc、snapshot
	Type             int64  `protobuf:"varint,1,opt,name=type" json:"type"`
  // 校验码
	Crc              uint32 `protobuf:"varint,2,opt,name=crc" json:"crc"`
	Data             []byte `protobuf:"bytes,3,opt,name=data" json:"data,omitempty"`
	XXX_unrecognized []byte `json:"-"`
}
```

`record`经过`encode`之后就被`write`到`file`对象当中

#### 初始化

初始化过程从`startNode`开始，主要做了如下几个动作

- 根据文件创建`wal dir`
- 生成`wal`的名称文件
- 对文件进行预置操作，默认是`64M`大小

```
➜  wal ll -h
total 8
-rw-------  1 admin  wheel    61M Dec 23 14:58 0.tmp
-rw-------  1 admin  wheel    61M Dec 23 14:58 0000000000000000-0000000000000000.wal
```

- 将`crc`写入
- 将`metadata`的数据写入进去
- 将`snapshot`数据写入
- 对文件进行重命名（0.tmp）
- 将重命名操作同步至`parent dir`

#### 其他操作

- `OpenWAL`：当`node`重启，获取销毁建立的时候，会根据先加载`snapshot`，根据`snapshot`的`index`来到`wal dir`当中获取指定的`wal`
- `Verify`：根据`snapshot`和`wal dir`来获取指定的`wal`,对其`crc`、`metadata`、`snapthot`进行校验，看看这个`wal`文件是否中间是否存在中断的情况，这个主要是用于测试用例；
- `Save`：在`node start|restart` 、`dump`、`restore命令`的时候会执行`wal save`操作，主要干了以下几个事情
  - 接收一个`	HardState`，包括：`term`、`vote`、`commit`；同时接收所需要保存的`entries`
  - `wal`对象里面的`state`与传入的`state`进行对比，校验`term`、`vote`是否相等
  - 开始保存`entry`，新建一个类型为`entry`的`record`，然后序列化，落盘
  - 同时将`wal`对象里面的`state`用`state`类型的`record`进行封装，序列化后落盘
  - 若文件的大小< `SegmentSizeBytes--64M`，直接`flush`，若大于，需要进行`cut`操作
- `cut`：将`offset`超出的部分，重新写入一个文件，再走一次`create`逻辑，这个时候`wal`的文件序列会+1，即`1.tmp`

### Snapshot

`snapshot`是一个快照，用于保存数据信息，便于恢复；经过压缩大小会比`wal`小；本篇是基于`etcdServer`里面的逻辑写的，`etcd`里面还有一个`raftexample/raft.go`，这个是一个简易版本，逻辑差不多，方便读者理解`raft`的逻辑；

#### 存储结构

从`pb`文件里面可以看到存储结构如下：

```protobuf
message Snapshot {
	optional bytes            data     = 1;
	optional SnapshotMetadata metadata = 2 [(gogoproto.nullable) = false];
}
message SnapshotMetadata {
	optional ConfState conf_state = 1 [(gogoproto.nullable) = false];
	optional uint64    index      = 2 [(gogoproto.nullable) = false];
	optional uint64    term       = 3 [(gogoproto.nullable) = false];
}
message ConfState {
	// The voters in the incoming config. (If the configuration is not joint,
	// then the outgoing config is empty).
	repeated uint64 voters = 1;
	// The learners in the incoming config.
	repeated uint64 learners          = 2;
	// The voters in the outgoing config.
	repeated uint64 voters_outgoing   = 3;
	// The nodes that will become learners when the outgoing config is removed.
	// These nodes are necessarily currently in nodes_joint (or they would have
	// been added to the incoming config right away).
	repeated uint64 learners_next     = 4;
	// If set, the config is joint and Raft will automatically transition into
	// the final config (i.e. remove the outgoing config) when this is safe.
	optional bool   auto_leave        = 5 [(gogoproto.nullable) = false];
}
```

在`raft/storage.go`当中可以看到`Storeage`是一个`interface`，目前只有一种基于内存的实现`MemoryStorage`

- 里面有一个互斥锁
- 有`snapshot`
- 还有对应的`entries`
- 这个`hardState`是用来记录这个快照的`term`、`vote`、`commit`

```go
type MemoryStorage struct {
	// Protects access to all fields. Most methods of MemoryStorage are
	// run on the raft goroutine, but Append() is run on an application
	// goroutine.
	sync.Mutex
	
	hardState pb.HardState
	snapshot  pb.Snapshot
	// ents[i] has raft log position i+snapshot.Metadata.Index
	ents []pb.Entry
}
```

#### 初始化

在`NewServer`的时候会初始化`snapshotter`

```go
	ss := snap.New(cfg.Logger, cfg.SnapDir())
```

#### 何时触发快照

`server`启动后，会有一个`forever`的处理，里面会有`apply`的操作，这个`applyAll`会触发快照的生成

```go
// etcdserver/server.go
......
for {
		select {
		case ap := <-s.r.apply():
			f := func(context.Context) { s.applyAll(&ep, &ap) }
			sched.Schedule(f)
			......
}
```

而这个`apply`是在`node start`的时候，同样启动了一个`forever`，监听`node Ready`通道；当上层业务通过调用`getSnapshot`的时候就会触发此`ready`操作，`Ready`是一个状态集合，维护着各种状态，是否可以读，可以写等；

另外，可以看一下测试类里面的代码：`etcdserver/server_test.go#TestTriggerSnap`

#### 生成快照

`getSnapshot`将用户需要做快照的数据进行传递过来，然后会进行两步操作

- 保存在wal：用`snapsho`t类型的`record`进行封装，然后序列化，落盘
- 保存snapshot：用`Snapshot`对象进行封装，然后序列化，落盘至`snapshot`的文件当中，`snapshot`文件命名格式为:`Term-Index.snap`

```go
	if err := rc.wal.SaveSnapshot(walSnap); err != nil {
		return err
	}
	if err := rc.snapshotter.SaveSnap(snap); err != nil {
		return err
	}
```

需要注意的：快照是`follower`在本地完成的，不需要`leader`向其发送消息；因为`follower`是完整的备份事项，`leader`只需要将`snapshot`所带的`term`和`index`传递过来即可；

```
func (r *raft) handleSnapshot(m pb.Message) {
	// message里面只是一个snapshot对象，包含index和term
   sindex, sterm := m.Snapshot.Metadata.Index, m.Snapshot.Metadata.Term
   if r.restore(m.Snapshot) {
      r.logger.Infof("%x [commit: %d] restored snapshot [index: %d, term: %d]",
         r.id, r.raftLog.committed, sindex, sterm)
      r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: r.raftLog.lastIndex()})
   } else {
      r.logger.Infof("%x [commit: %d] ignored snapshot [index: %d, term: %d]",
         r.id, r.raftLog.committed, sindex, sterm)
      r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: r.raftLog.committed})
   }
}
```