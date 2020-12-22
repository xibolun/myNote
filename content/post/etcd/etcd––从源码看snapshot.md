---

date :  "2020-07-05T14:32:00+08:00" 
title : "etcd––从源码看snapshot" 
categories : ["技术文章"] 
tags : ["etcd"] 
toc : true
---

## Snapshot

`snapshot`是一个快照，用于保存数据信息，便于恢复；本篇是基于`etcdServer`里面的逻辑写的，`etcd`里面还有一个`raftexample/raft.go`，这个是一个简易版本，逻辑差不多，方便读者理解`raft`的逻辑；

### 存储结构

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

### 初始化

在`NewServer`的时候会做几个动作

- 初始化`wal`

- 初始化`snapshotter`

```
	ss := snap.New(cfg.Logger, cfg.SnapDir())
```

### 何时生成快照

`server`启动后，会有一个`forever`的处理，里面会有`apply`的操作，这个`applyAll`会触发快照的生成

```go
......
for {
		select {
		case ap := <-s.r.apply():
			f := func(context.Context) { s.applyAll(&ep, &ap) }
			sched.Schedule(f)
			......
}
```

而这个`apply`是在`node start`的时候，同样启动了一个`forever`，监听`node Ready`通道