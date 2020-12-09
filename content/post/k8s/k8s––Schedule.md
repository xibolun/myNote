---

date :  "2020-03-11T20:41:03+08:00" 
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
- `prioritizeNodes`：对`node`进行优选，其实是就`ScorePlugin`打分
- `selectHost`：最终根据打出来的分，找最高的node返回，只会返回一个

