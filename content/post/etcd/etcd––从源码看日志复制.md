---

date :  "2020-07-04T09:45:47+08:00" 
title : "etcd––从源码看日志复制" 
categories : ["etcd"] 
tags : ["etcd"] 
toc : true
---

## 日志复制

### 日志对象

`etcd`把一条日志做为一个`entry`，每一个里面都会有几个属性：

- `Term`：`leader`的任期，这个属性的目的乃是`follower`接收到`msgApp`类型的消息的时候，会与本地维护的`Term`进行对比，防止出现不是最新的`leader`，以便可以重新发起选举
- `Index`，`leader`维护的日志信息当中最大的索引
- `Type`，日志类型，因为`etcd`当中最早使用的是`entryConfChange`现在升级到2版本，主要加了事务的功能；
- `Data`，日志信息，是使用`entryConfChange2`结构体进行序列化的结果

```go
type Entry struct {
	Term             uint64    `protobuf:"varint,2,opt,name=Term" json:"Term"`
	Index            uint64    `protobuf:"varint,3,opt,name=Index" json:"Index"`
	Type             EntryType `protobuf:"varint,1,opt,name=Type,enum=raftpb.EntryType" json:"Type"`
	Data             []byte    `protobuf:"bytes,4,opt,name=Data" json:"Data,omitempty"`
	XXX_unrecognized []byte    `json:"-"`
}
```

### 日志复制过程

#### 发起

当`client`向`etcd-server`发起一条`msg`的时候（比如`etcdctl put key value`），这个时候的会通过`rpc`调用至`etcdserver`，`etcdserver`在处理的时候，会将这条数据进行封装

- 类型为`MsgProp`
- 消息体为`Entry`

```go
func (n *node) Propose(ctx context.Context, data []byte) error {
	return n.stepWait(ctx, pb.Message{Type: pb.MsgProp, Entries: []pb.Entry{{Data: data}}})
}
```

然后将这条消息放入到`node的propc`的`channel`当中

```go
// Step advances the state machine using msgs. The ctx.Err() will be returned,
// if any.
func (n *node) stepWithWaitOption(ctx context.Context, m pb.Message, wait bool) error {
	......
	ch := n.propc
	pm := msgWithResult{m: m}
	if wait {
		pm.result = make(chan error, 1)
	}
	select {
    // 将pm写入channel，node监听拿到pm，这就是go channel的好处哇；
	case ch <- pm:
		if !wait {
			return nil
		}
	.....
}
```

而`node run`的时候会有一个`forever`的进程，一直在监听着`channel`，直接就进入`leader`的`stepLeader`方法当中

```go
		case pm := <-propc:
			m := pm.m
			m.From = r.id
			// 进入r.Step，因为leader的Term比较大，所以直接就进行StepLeader
			err := r.Step(m)
			if pm.result != nil {
				pm.result <- err
				close(pm.result)
			}
```

#### Leader处理过程

##### Leader本地处理

- 对日志进行`unmarshal`
- 判断日志是否可以进行追加
  - 已经存在待追加的消息
  - 已经joint，事务还未提交（根据节点维护的`ProgressTracker`记录着`follower`当前的状态来判断）
  - 存在正在提交事务
- 若可以则进行将`pendingConfIndex+1`，并进行日志追加广播
  - 追加日志广播的时候一样的逻辑，消息类型为`msgApp`，消息体为`entry`，并带上自身的`LogTerm`和`Index`

![leader send entry](/img/etcd/etcd-election-send-entry.jpg)

```go
case pb.MsgProp:
		......
		// 开始处理entry
		for i := range m.Entries {
      // 反序列化得到消息
			e := &m.Entries[i]
      ......
				var ccc pb.ConfChangeV2
				if err := ccc.Unmarshal(e.Data); err != nil {
					panic(err)
				}
				cc = ccc
			if cc != nil {
        // 判断是否可以追加
				alreadyPending := r.pendingConfIndex > r.raftLog.applied
				alreadyJoint := len(r.prs.Config.Voters[1]) > 0
				wantsLeaveJoint := len(cc.AsV2().Changes) == 0

				var refused string
				if alreadyPending {
					refused = fmt.Sprintf("possible unapplied conf change at index %d (applied to %d)", r.pendingConfIndex, r.raftLog.applied)
				} else if alreadyJoint && !wantsLeaveJoint {
					refused = "must transition out of joint config first"
				} else if !alreadyJoint && wantsLeaveJoint {
					refused = "not in joint state; refusing empty conf change"
				}

				if refused != "" {
					r.logger.Infof("%x ignoring conf change %v at config %s: %s", r.id, cc, r.prs.Config, refused)
					m.Entries[i] = pb.Entry{Type: pb.EntryNormal}
				} else {
					r.pendingConfIndex = r.raftLog.lastIndex() + uint64(i) + 1
				}
			}
		}

		if !r.appendEntry(m.Entries...) {
			return ErrProposalDropped
		}
		r.bcastAppend()
		return nil
```

##### Follower远程处理

`follower`接收到消息之后的逻辑

- 比对一个`Term`，看看`leader`是不是最新的
- 开始尝试追加
- 最后返回给`leader`一个`MsgAppResp`的消息类型

![follower resp](/img/etcd/etcd-election-heartbeat.jpg)

```go
func (r *raft) handleAppendEntries(m pb.Message) {
	if m.Index < r.raftLog.committed {
		r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: r.raftLog.committed})
		return
	}

	if mlastIndex, ok := r.raftLog.maybeAppend(m.Index, m.LogTerm, m.Commit, m.Entries...); ok {
		r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: mlastIndex})
	} else {
		r.logger.Debugf("%x [logterm: %d, index: %d] rejected MsgApp [logterm: %d, index: %d] from %x",
			r.id, r.raftLog.zeroTermOnErrCompacted(r.raftLog.term(m.Index)), m.Index, m.LogTerm, m.Index, m.From)
		r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: m.Index, Reject: true, RejectHint: r.raftLog.lastIndex()})
	}
}
```

##### follower追加逻辑

对比本地`index`和`Term`；每一个节点上面都会维护一个`raftLog`，它里面包含已存储的日志`Storage`，已提交的日志索引(Commited)、未提交的`unstable`，已同意提交的`applied`（其中这个属性的值会<=committed）

- `entry`的`index`需要比`unstable`和`storage`的最大值还要大；

- `entry`的`term`需要比`unstable`和`storage`的`Term`最大值还要大，都取最后一条日志的上一条的`Term`进行对比；这也是为什么`etcd`能够做到数据版本历史的原因

- 若以上条件都满足，对每个`entry`是否已经被包含了,然后再进行一次`commit`，这个逻辑比较简单，直接将`committed`修改为最新需要`commit`的`index`即可

- 做完这一切会向`Leader`发送一个`MsgAppResp`的消息，包括自己的`id`,最新的日志信息`index`；若是拒绝的，则会发送自身最新的日志信息，将其放在`RejectHint`属性当中

##### Leader接收MsgAppResp

在`stepLeader` `function`当中可以看到收到`MsgAppResp`的消息后，`Leader`做了以下处理：

- 若是拒绝消息，因为有可能`follower`的日志比较旧，跟不上`leader`，那么`leader`就会根据`RejectHint`来降低自己的日志索引，然后发给`follower`，同时将`progress`里面`follower`的状态维护为`StateProbe`，意思是这个伙计现在有点问题，直至恢复

- 若是成功消息，则对此`follower`的`progress`里面的状态进行判断

  - 若为`Probe`，修改为`Replicate`
  - 若为`snapshot`，说明是需要做快照了
  - 若为`replicate`，则需要开始提交`commit`了；
  - 若没有问题，将`leader`的commit索引更新，然后广播可以提交的append消息，只不过这一次发送的时候`progress`的状态不同；

  ```go
  				if r.maybeCommit() {
  				// 广播发送
  					r.bcastAppend()
  ```

  ```go
  		m.Type = pb.MsgApp
  		m.Index = pr.Next - 1
  		m.LogTerm = term
  		m.Entries = ents
  		m.Commit = r.raftLog.committed
  		if n := len(m.Entries); n != 0 {
  			switch pr.State {
  			// optimistically increase the next when in StateReplicate
        // 再次发送时，state为replicate
  			case tracker.StateReplicate:
  				last := m.Entries[n-1].Index
  				pr.OptimisticUpdate(last)
  				pr.Inflights.Add(last)
         // 第一次发送是为probe状态
  			case tracker.StateProbe:
  				pr.ProbeSent = true
  			default:
  				r.logger.Panicf("%x is sending append in unhandled state %s", r.id, pr.State)
  			}
  		}
  ```

可以看到当`etcdserver`接受到命令的时候，并不是直接就执行，而是先放在本地的`unstable`里面，然后再向`follower`发送，等大多数的`follower`返回结果，自己才会进行更新至`commit`里面；而整个过程都是维护在`ProgressTracker`当中；

  ```go
  type ProgressTracker struct {
  	Config
    Progress ProgressMap 
  	Votes map[uint64]bool  
  	MaxInflight int
  }
  ```

- ProgressMap是以follower的id为key，对应的value为一个`Progress`的指针，维护着`follower`的状态
  - 状态类型，`probe`、`replicate`、`snapshot`

```go
type Progress struct {
	Match, Next uint64
	State StateType
  // 等待快照的数量
	PendingSnapshot uint64
  // 是否活跃，即收到了任何的message都会设置为true
	RecentActive bool
  // 当为true时，follower就无法向其发送信息，直到follower修改状态
	ProbeSent bool
  // 这个是航班，每开始同步日志的时候，就会将其尾部的去掉，将新的日志index加入进去；
	Inflights *Inflights
  // 刚开始的节点或者角色发生变化 后，状态为learner；
	IsLearner bool
}
```

