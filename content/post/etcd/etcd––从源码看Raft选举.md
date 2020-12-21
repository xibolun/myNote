---

date :  "2020-07-03T15:48:17+08:00" 
title : "etcd––从源码看raft选举" 
categories : ["技术文章"] 
tags : ["etcd"] 
toc : true
---

### Raft算法

分布式一致性算法最出名的是`paxos`，但是因为其非常难以理解，所以便有了简单可理解的`raft`算法；`Raft`将分布式问题归为几个模块来解决

- 领袖选举：`raft`使用非对称节点的方式，必须有一个节点说了算
- 日志复制：将主节点的日志条目`entry`同步至其他节点当中，保持一致性
- 安全性：节点挂了，然后再重启的一些问题场景
- 成员关系变化 ：当配置发生变化的时候，节点还可以正常执行

Raft同时搞了几个角色和名词

- `leader`：领袖节点，此节点有话语权，通知其他节点强制更新自己的数据条目
- `follwer`：群众，老百姓，受`leader`管控，同时可以发起选举投票；
- `candidate`：候选人，每一个`follower`在选举过程当中都可以成功候选人，若投票成功会变成`leader`
- `term`：任期，是一个整数类型的时间，当`leader`任期到了，就会发起选举；同时每一个节点里面都有最新的`term`，当`leader`发送一些信息的时候，可以校验这个`leader`任期是否到了；

### 选举过程

#### 发起投票

- 当`follower`的选举定时器时间到了（长时间没有收到`leader`的消息），就会发起一次投票选举；

```go
// tickElection is run by followers and candidates after r.electionTimeout.
func (r *raft) tickElection() {
	r.electionElapsed++

	if r.promotable() && r.pastElectionTimeout() {
		r.electionElapsed = 0
		// 开始发起一次
		r.Step(pb.Message{From: r.id, Type: pb.MsgHup})
	}
}
```

此计时器是一个随机的时间，在每次`reset`的时候都会启动一个

```go
func (r *raft) resetRandomizedElectionTimeout() {
	r.randomizedElectionTimeout = r.electionTimeout + globalRand.Intn(r.electionTimeout)
}
```

#### 源节点的变化

- 角色修改为`candidate`
- 重置计数器
- 投票的对象变为自身
- 开始接收其他节点的信息

```go
func (r *raft) becomeCandidate() {
	// TODO(xiangli) remove the panic when the raft implementation is stable
	if r.state == StateLeader {
		panic("invalid transition [leader -> candidate]")
	}
  // stepCandidate是一个函数，处理消息
	r.step = stepCandidate
	r.reset(r.Term + 1)
	r.tick = r.tickElection
	r.Vote = r.id
  // StateCandidate常量
	r.state = StateCandidate
	r.logger.Infof("%x became candidate at term %d", r.id, r.Term)
}
```

campaign函数即为处理每一次选举，投票，追加日志，心跳等所有信息的入口

#### 接收其他节点的消息

此逻辑即为上面提到的`stepCandidate`函数，由于其他节点的消息可能会有多种存在，这些消息都会有类型，根据不同的类型，源节点也会进行不同的操作；

##### AppendEntry

这个是追加日志的消息，说明外面已经有`leader`了，源节点自动变为`follower`，并处理`appendEntry`，

```go
	case pb.MsgApp:
		r.becomeFollower(m.Term, m.From) // always m.Term == r.Term
		r.handleAppendEntries(m)
```

变成`follower`也很简单

- 节点状态修改为`follower`
- 重置计数器
- 设置`leader`
- 设置`term`

```go
func (r *raft) becomeFollower(term uint64, lead uint64) {
  // 做为一个follower，需要接收消息
	r.step = stepFollower
	r.reset(term)
	r.tick = r.tickElection
	r.lead = lead
	r.state = StateFollower
	r.logger.Infof("%x became follower at term %d", r.id, r.Term)
}
```

处理`entry`的逻辑有几个判断

- 因为外面的`leader`可能是旧的`leader`，所以需要判断一下它的`term`
- 有可能`follower`的日志与`leader`的日志相关比较远，那就返回一个`reject`消息，同时将自己最新的`logId`返回，这样`leader`就知道这个`follower`差了多少的日志，再给他发过来，让他强制更新

```go
func (r *raft) handleAppendEntries(m pb.Message) {
  // 是不是最新的日志？
	if m.Index < r.raftLog.committed {
		r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: r.raftLog.committed})
		return
	}

  // 开始追加
	if mlastIndex, ok := r.raftLog.maybeAppend(m.Index, m.LogTerm, m.Commit, m.Entries...); ok {
		r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: mlastIndex})
	} else {
    // 日志对不上号，与leader相比少了
		r.logger.Debugf("%x [logterm: %d, index: %d] rejected MsgApp [logterm: %d, index: %d] from %x",
			r.id, r.raftLog.zeroTermOnErrCompacted(r.raftLog.term(m.Index)), m.Index, m.LogTerm, m.Index, m.From)
		r.send(pb.Message{To: m.From, Type: pb.MsgAppResp, Index: m.Index, Reject: true, RejectHint: r.raftLog.lastIndex()})
	}
}
```

##### heartbeat

外面的`leader`来视察，看看`follower`是否还活着，那节点就需要放弃投票，变成`follower`，同时执行心跳并返回

```go
	case pb.MsgHeartbeat:
		r.becomeFollower(m.Term, m.From) // always m.Term == r.Term
		r.handleHeartbeat(m)
```

##### snapshot

外面的`leader`来添加快照，那节点就需要放弃投票，变成`follower`，同时执行快照的逻辑

```go
	case pb.MsgSnap:
		r.becomeFollower(m.Term, m.From) // always m.Term == r.Term
		r.handleSnapshot(m)
```

##### vote

其他节点会发送一个`voteResp`类型的消息，这个消息里面包含着两个重要属性

- from：投票来自哪个节点，即对方节点的id
- Reject：拒绝消息，取反 !Reject，即投的反对票、支持票；

```go
		gr, rj, res := r.poll(m.From, m.Type, !m.Reject)
```
节点会进行计票
```shell
func (r *raft) poll(id uint64, t pb.MessageType, v bool) (granted int, rejected int, result quorum.VoteResult) {
	if v {
		r.logger.Infof("%x received %s from %x at term %d", r.id, t, id, r.Term)
	} else {
		r.logger.Infof("%x received %s rejection from %x at term %d", r.id, t, id, r.Term)
	}
	r.prs.RecordVote(id, v)
	return r.prs.TallyVotes()
}
```

若节点所获得的票数大于`n/2+1`，则表示胜出

```go
func (c MajorityConfig) VoteResult(votes map[uint64]bool) VoteResult {
	if len(c) == 0 {
		// By convention, the elections on an empty config win. This comes in
		// handy with joint quorums because it'll make a half-populated joint
		// quorum behave like a majority quorum.
		return VoteWon
	}

	ny := [2]int{} // vote counts for no and yes, respectively

	var missing int
	for id := range c {
		v, ok := votes[id]
		if !ok {
			missing++
			continue
		}
		if v {
			ny[1]++
		} else {
			ny[0]++
		}
	}

  // n/2+1
	q := len(c)/2 + 1
  // 投票数大于 n/2+1
	if ny[1] >= q {
		return VoteWon
	}
  // 投票数 + 未投票数 大于q，则继续等待那些没有投的票
	if ny[1]+missing >= q {
		return VotePending
	}
  // 投票失败
	return VoteLost
}
```

若投票成功，则变成`leader`，失败则变成`follower`

```go
	switch res {
		case quorum.VoteWon:
			// 若是预选举，则进行真正的选举，这个在真实的生产环境当中没有使用
			if r.state == StatePreCandidate {
				r.campaign(campaignElection)
			} else {
        // 成为leader
				r.becomeLeader()
        // 广播一个空的追加日志消息，让其他节点修改自己的term，和leaderId
				r.bcastAppend()
			}
		case quorum.VoteLost:
			// pb.MsgPreVoteResp contains future term of pre-candidate
			// m.Term > r.Term; reuse r.Term
			r.becomeFollower(r.Term, None)
		}
```

### 几个问题

#### 选举不出来怎么办？

活着的`follower`不足，导致大家计票数都一样；比如3个节点，挂了一个，其他两个节点各得一票，无法胜出，怎么办呢？这个时候就会走超时逻辑，然后每个`follower`的选举随机计时器触发即可；

#### 其他节点什么时候投反对、支持？

- 其他节点什么时候投支持、什么时候投反对呢？当节点接收到一个类型为`msgVote`消息的时候，这个里面有几个重要的属性

  - from：消息来源，即发起投票的节点id

  - term：发起节点的term

  - logTerm：发起节点发起投票前的term

  - index: 发起节点log的index

- 投票逻辑如下：

  - 校验自己是否具备投票的资格，几种情况可以投票：

    - 已经投过此节点，咱可以再投
  - 节点是没有投过票、节点没有`leader`，
    - 节点所记录的`term`比消息来源节点的短；
  - 若不满足上面的条件，就投反对票
  - 若满足，则拿发起节点的历史term和logIndex进行比对，若本地的比发起节点的超前，那就投反对票（如节点down了很久，重新发起投票，日志已经很久没有更新）；若比投票节点老，则人他一票吧；
- 不管投支持、反对票，都会将本地的投票计时器清0

```go
case pb.MsgVote, pb.MsgPreVote:
		// We can vote if this is a repeat of a vote we've already cast...
		canVote := r.Vote == m.From ||
			// ...we haven't voted and we don't think there's a leader yet in this term...
			(r.Vote == None && r.lead == None) ||
			// ...or this is a PreVote for a future term...
			(m.Type == pb.MsgPreVote && m.Term > r.Term)
		// ...and we believe the candidate is up to date.
		// 校验一下是不是最新的，
		if canVote && r.raftLog.isUpToDate(m.Index, m.LogTerm) {
			r.send(pb.Message{To: m.From, Term: m.Term, Type: voteRespMsgType(m.Type)})
			if m.Type == pb.MsgVote {
				// Only record real votes.
				r.electionElapsed = 0
				r.Vote = m.From
			}
		} else {
			r.logger.Infof("%x [logterm: %d, index: %d, vote: %x] rejected %s from %x [logterm: %d, index: %d] at term %d",
				r.id, r.raftLog.lastTerm(), r.raftLog.lastIndex(), r.Vote, m.Type, m.From, m.LogTerm, m.Index, r.Term)
			r.send(pb.Message{To: m.From, Term: r.Term, Type: voteRespMsgType(m.Type), Reject: true})
		}
```

#### 如何控制节点不发起投票

`leader`会向每个`follower`发一个心跳，每发一次就会将`follower`的投票计时器清0

#### 来了新加节点怎么办？

新加的节点默认是`follower`，此时它没有`leader`，`term`也会0，这时候会有两种情况

- 若在投票计时器没有到点的时候，收到`leader`的心跳消息，则更新`leader`和`term`信息；
- 若投票计时器到点了，那此时就会发起投票；`leader`会收到一个投票的消息，一看`term`和`index`都不是最新的，直接投否定票，即发一个`reject`消息给它，然后心跳时间到了，再发一个心跳给它，前面防止它从`candidate`成为`leader`，后者直接将其从`candidate`变为`follower`

#### leader挂了怎么办？

`leader`挂了，就不会再有心跳，`follower`进入选举过程；

