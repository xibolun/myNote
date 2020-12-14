---

date :  "2020-03-12T20:41:03+08:00" 
title : "k8s––schedule" 
categories : ["技术文章"] 
tags : ["k8s"] 
toc : true
---

> 源码根据`k8s : v1.18.12`版本

创建一个`Pod`的时候到底归属到哪个`Node`上面呢？这在`k8s`里面是有非常精细的一套调度逻辑；

### 调度原理

- 通过`cobra`开始启动命令服务
- 创建`schedule`
- 加载配置信息，从`queueSort`、`PreFilter`、`Filter`、`PreScore`、`Score`、`Bind`

```go
// pkg/scheduler/algorithmprovider/registry.go method getDefaultConfig
```

这些都是插件，可以从启动的参数里面通过`options`传递，也可以使用默认的；在`framework/plugins`下面有许多的插件，每个插件的方法都可能会有`queueSort`、`PreFilter`、`Filter`、`PreScore`、`Score`、`Bind`的`interface`实现；

```
➜  plugins git:(release-1.18.12) tree -d
.
├── defaultbinder
├── defaultpodtopologyspread
├── examples
│   ├── multipoint
│   ├── prebind
│   └── stateful
├── helper
├── imagelocality
├── interpodaffinity
├── nodeaffinity
├── nodelabel
├── nodename
├── nodeports
├── nodepreferavoidpods
├── noderesources
├── nodeunschedulable
├── nodevolumelimits
├── podtopologyspread
├── queuesort
├── serviceaffinity
├── tainttoleration
├── volumebinding
├── volumerestrictions
└── volumezone
```

- 监听`pod`的列表，会有一个`pod queue`，当一个`pod`结束后，会进行下一个`pod`

```go
// Run begins watching and scheduling. It waits for cache to be synced, then starts scheduling and blocked until the context is done.
func (sched *Scheduler) Run(ctx context.Context) {
  // 监听pod是否完成，若没有完成，则继续等待
	if !cache.WaitForCacheSync(ctx.Done(), sched.scheduledPodsHasSynced) {
		return
	}
	sched.SchedulingQueue.Run()
  // 开始调度一个pod，从pod queue当中
	wait.UntilWithContext(ctx, sched.scheduleOne, 0)
	sched.SchedulingQueue.Close()
}
```

- 开始进行调试，接口主要实现是`genericScheduler`
- `podPassesBasicChecks`：校验`pod`基础信息，主要是校验`pvc`是否存在，名称是否异常
- `RunPreFilterPlugins`： 先执行`PreFilter`，这些`filter`都在上面的那些`plugins`里面实现
- `findNodesThatFitPod`：执行`Filter`接口实现
- `RunPreScorePlugins`： 预先打分
- `prioritizeNodes`：对`node`进行优选，其实就是`ScorePlugin`打分
- `selectHost`：最终根据打出来的分，找最高的node返回，只会返回一个

### 如何打分

> 本例当中的`pre-score`和`score`都以`interpodaffinity`为例

#### 亲和与反亲和

以`interpodaffinity`为例；用户会有`pod`的`spec`当中配置的`Affinity`属性，`Affinity`分为`Node-Affinity`、`Pod-Affinity`、`PodAntiAffinity`；他们都有以下两个属性，但是实际上在源码当中每个对象都定义了一个结构体，可能后续也是为了补充其他的属性；

- `requiredDuringSchedulingIgnoredDuringExecution`：表示pod必须部署到满足条件的node之上，若没有，则会进行重试
- `preferredDuringSchedulingIgnoredDuringExecution`：优先部署到满足条件的node上，若没有，则忽略条件部署即可

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: topology.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: topology.kubernetes.io/zone
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0
```


#### pre-score过程

`PodAffinity`会生成`affinityTerms`；而`PodAntiAffinity`会生成`antiAffinityTerms`，他们都是`[]weightedAffinityTerm`，里面存放着指标和权重

```go
// A "processed" representation of v1.WeightedAffinityTerm.
type weightedAffinityTerm struct {
	affinityTerm
	weight int32
}
```

`PodAffinity`打分

```go
// pkg/scheduler/framework/plugins/interpodaffinity/scoring.go
func (pl *InterPodAffinity) processTerm(
	state *preScoreState,
	term *weightedAffinityTerm,
	podToCheck *v1.Pod,
	fixedNode *v1.Node,
	multiplier int,
) {
	if len(fixedNode.Labels) == 0 {
		return
	}

	match := schedutil.PodMatchesTermsNamespaceAndSelector(podToCheck, term.namespaces, term.selector)
	tpValue, tpValueExist := fixedNode.Labels[term.topologyKey]
	if match && tpValueExist {
		pl.Lock()
		if state.topologyScore[term.topologyKey] == nil {
			state.topologyScore[term.topologyKey] = make(map[string]int64)
		}
    // 亲和属性的值加上 权重*乘数，这个乘数是从上面传过来的，下面的代码片断里面有说明
		state.topologyScore[term.topologyKey][tpValue] += int64(term.weight * int32(multiplier))
		pl.Unlock()
	}
	return
}
```

```go
	// For every soft pod affinity term of <pod>, if <existingPod> matches the term,
	// increment <p.counts> for every node in the cluster with the same <term.TopologyKey>
	// value as that of <existingPods>`s node by the term`s weight.
	// 若pod的软亲和力在已经存在的Pod当中有，那么将所有的存在此属性的pod所在的node节点增长1
	pl.processTerms(state, state.affinityTerms, existingPod, existingPodNode, 1)
	// For every soft pod anti-affinity term of <pod>, if <existingPod> matches the term,
	// decrement <p.counts> for every node in the cluster with the same <term.TopologyKey>
	// value as that of <existingPod>`s node by the term`s weight.
	// 若pod的软非亲和力在已经存在的Pod当中有，那么将所有的存在此属性的pod所在的node节点减去1
	pl.processTerms(state, state.antiAffinityTerms, existingPod, existingPodNode, -1)
```

最终生成一个`preScoreState`对象，放入`cycleState`当中，这个`preScoreStateKey`即为不同的实现的名称，在此例当中即为`PreScoreInterPodAffinity`；

```go
	cycleState.Write(preScoreStateKey, state)
```

#### score过程

`pkg/scheduler/framework/plugins/interpodaffinity/scoring.go`

```go
// Score invoked at the Score extension point.
// The "score" returned in this function is the matching number of pods on the `nodeName`,
// it is normalized later.
func (pl *InterPodAffinity) Score(ctx context.Context, cycleState *framework.CycleState, pod *v1.Pod, nodeName string) (int64, *framework.Status) {
	nodeInfo, err := pl.sharedLister.NodeInfos().Get(nodeName)
	if err != nil || nodeInfo.Node() == nil {
		return 0, framework.NewStatus(framework.Error, fmt.Sprintf("getting node %q from Snapshot: %v, node is nil: %v", nodeName, err, nodeInfo.Node() == nil))
	}
	node := nodeInfo.Node()

  // 获取 pre-score的state信息
	s, err := getPreScoreState(cycleState)
	if err != nil {
		return 0, framework.NewStatus(framework.Error, err.Error())
	}
 // 将分数值进行累加，即为对应传递进来node的分数值，完成对`Node`的`interpodaffinity`打分
	var score int64
	for tpKey, tpValues := range s.topologyScore {
		if v, exist := node.Labels[tpKey]; exist {
			score += tpValues[v]
		}
	}

	return score, nil
}
```

### 其他的一些打分实现

- `noderesources--NodeResourcesBalancedAllocation`：根据`node`的`cpu\memory\storage\scale`
- `noderesources--NodeResourcesLeastAllocated`：
- `nodeaffinity`：根据`pod`当中的`NodeAffinity`当中的属性和权重来计算
- `defaultpodtopologyspread`：默认的`pod`拓扑，即根据`labels`确定的数量即为分值
- `nodepreferavoidpods––NodePreferAvoidPods`，将`ReplicationController`、`ReplicaSet`的`controller`分值设置 为100;
- `tainttoleration––TaintToleration`：根据`Pod spec`的`Tolerations`和`Node spec`的`Taints`配置来计算分值
- `imagelocality`：根据`Pod`请求的`image size` *( (`使用此image的nodeNum`)/`totalNumNodes`)，然后再根据区间进行算分

```go
func scaledImageScore(imageState *schedulernodeinfo.ImageStateSummary, totalNumNodes int) int64 {
	spread := float64(imageState.NumNodes) / float64(totalNumNodes)
	return int64(float64(imageState.Size) * spread)
}
```

```go
// calculatePriority returns the priority of a node. Given the sumScores of requested images on the node, the node's
// priority is obtained by scaling the maximum priority value with a ratio proportional to the sumScores.
func calculatePriority(sumScores int64) int64 {
  // 上限 23mb
	if sumScores < minThreshold {
		sumScores = minThreshold
    // 下线 1000mb
	} else if sumScores > maxThreshold {
		sumScores = maxThreshold
	}
	// MaxNodeScore=100
	return int64(framework.MaxNodeScore) * (sumScores - minThreshold) / (maxThreshold - minThreshold)
}
```

