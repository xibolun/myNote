---

date :  "2020-03-16T17:50:01+08:00" 
title : "k8s—informer机制" 
categories : ["k8s"] 
tags : ["k8s"] 
description: k8s informer
---

## K8s Informer机制

`informer`是`k8s`里面的重要通讯机制，理解了它，有助于我们对`k8s`进行二次开发，像`operator`等；看一下简单的实现

```go
package main

import (
	"context"
	"fmt"
	"log"

	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {
	// 简单起见硬编码相关配置
	configPath := "/Users/admin/Documents/etc/k8s/config/kubeconfig.yaml"
	masterURL := "https://10.0.4.175:6443"

	// 初始化config
	config, err := clientcmd.BuildConfigFromFlags(masterURL, configPath)
	if err != nil {
		panic(err)
	}

	// 初始化client
	kubeClient, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err)
	}

	depList, _ := kubeClient.AppsV1().Deployments("idcos").List(context.Background(), metav1.ListOptions{LabelSelector: ""})

	for _, v := range depList.Items {
		log.Printf("namespace: %s, name: %s", v.Namespace, v.Name)
	}

	fmt.Printf("connection k8s success \n")

	// 获取工厂实例, 通过这个工厂实例可获取到所有资源的 Informer
	factory := informers.NewSharedInformerFactory(kubeClient, 0)
	// 创建Pod Informer
	podInformer := factory.Core().V1().Pods()
	informer := podInformer.Informer()

	// 创建ns informer
	ns := factory.Core().V1().Namespaces()
	nsformer := ns.Informer()

	stopCh := make(chan struct{})
	defer close(stopCh)
	go factory.Start(stopCh)

	if !cache.WaitForCacheSync(stopCh, informer.HasSynced) {
		log.Fatal("sync failed")
	}

	nsformer.AddEventHandler(cache.ResourceEventHandlerFuncs{
    // 当有namespace创建的时候，会打印出来
		AddFunc: func(obj interface{}) {
			ns := obj.(*v1.Namespace)
			log.Println("get a namesapce:", ns.Name)
		},
    // 当有namespace更新的时候，会打印出来
		UpdateFunc: func(oldObj, newObj interface{}) {
			log.Printf("update namespace %s -> %s", oldObj.(*v1.Namespace).Name, newObj.(*v1.Namespace).Name)
		},
    // 当有namespace删除的时候，会打印出来
		DeleteFunc: func(obj interface{}) {
			log.Println("delete a namespace", obj.(*v1.Namespace).Name)
		},
	})

  // 拿到所有的namespace
	nsLister := ns.Lister()
	nsList, err := nsLister.List(labels.Everything())
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(nsList)

	<-stopCh
}

```

> 代码当中的配置文件是在`k8s`集群当中的`cat ~/.kube/config`当中，将其copy至本地即可开始`debug`

这个例子里面的大概意思可以描述为用户通过`kubectl`命令操作`ApiServer`的种种行为，都可以被监听到，用户可以对这些事件通过注册`Handler`的方式进行扩展操作；那他怎么实现的呢？先看一张官方的图，有一个大概的了解，后面会详情地理一理；

![k8s informer](/img/k8s/t01dcd05613a7827aa1.jpg)

这张图刚看起来可能比较抽象；我的思路是以`obj`为主体，跟踪它的流转情形；当看完源码后，再来看这张图就会比较清晰了；

### Delta

当我们使用了`kubectl create ns idcos`这样一条命令的时候，肯定是先调用至`apiserver`，若`apiserver`将这些变动封装成对象的对象，通知其他模块我做了`update/delete/add`等操作后，其他模块即可继续向下走，完成自己的逻辑，所以本质上就是对这些`update/delete/add`的事件操作；

这些事件都会被封装为一个一个的`Delta`，`Type`主要包括五种，`add/update/delete/replace/sync`

```go
type Delta struct {
	Type   DeltaType
	Object interface{}
}
```

### Reflector

`ApiServer`接收发送请求会非常的多，肯定有一个模块是用来监听它的，这个便是`Reflector`；它有两个方法，一个是`List`，用于监听全量的信息；一个是`Watch`用于监听增量的信息；

```go
// staging/src/k8s.io/client-go/tools/cache/reflector.go
func (r *Reflector) ListAndWatch(stopCh <-chan struct{}) error {}
func (r *Reflector) watchHandler(start time.Time, w watch.Interface, resourceVersion *string, errc chan error, stopCh <-chan struct{}) error {}
```

`Watch`出来的`event`会有`add/update/delete`操作，这些数据会被封装为`Delta`，然后进入到`Delta FIFO queue`当中

### Controller

这个`Controller`是与我们`k8s`里面的`controller`不是一回事，只是代码起了这个名字，它在初始化完成后，会有一个`loop`，将`Delta FIFO queue`里面的`obj pop`给`Informer`

```go
func (c *controller) processLoop() {
	for {
		obj, err := c.config.Queue.Pop(PopProcessFunc(c.config.Process))
		if err != nil {
			if err == ErrFIFOClosed {
				return
			}
			if c.config.RetryOnError {
				// This is the safe way to re-enqueue.
				c.config.Queue.AddIfNotPresent(obj)
			}
		}
	}
}
```

在`Pop`的时候会有一个`process`，这个对应的便是`HandleDeltas`

```go
func (f *DeltaFIFO) Pop(process PopProcessFunc) (interface{}, error) {
		......
		err := process(item)
		......
}
```

### Indexer

这些`obj`对象需要变更，存储，否则没有办法知道现在是什么状况；`Indexer`的职责就是用于存储这些`obj`，当`informer`接收到`obj`后，通过`HandleDeltas`会将`add/update/delete`的操作给`Indexer`，这时`Indexer`就会进行存储；

以`Add`为例，这个时候的操作，是更新至内存当中，其实现方法为：

```go
// staging/src/k8s.io/client-go/tools/cache/store.go 
// Add inserts an item into the cache.
func (c *cache) Add(obj interface{}) error {
	key, err := c.keyFunc(obj)
	if err != nil {
		return KeyError{obj, err}
	}
	c.cacheStorage.Add(key, obj)
	return nil
}
```

持久化对象结构乃是一个`map`；

```go
// threadSafeMap implements ThreadSafeStore
type threadSafeMap struct {
	lock  sync.RWMutex
	items map[string]interface{}

	// indexers maps a name to an IndexFunc
	indexers Indexers
	// indices maps a name to an Index
	indices Indices
}
```

### Informer

`HandleDeltas`对`obj`进行处理，通过`processor`进行`distribute`至`listener`，同时将`obj`转换为`notification`添加至`listener`的`addChannel`当中;

- `processor`： informer的一个对象，在初始化的时候会创建出来；它的作用是对`obj`进行处理，通过`listner`干活

```go
func (s *sharedIndexInformer) HandleDeltas(obj interface{}) error {
	s.blockDeltas.Lock()
	defer s.blockDeltas.Unlock()

	// from oldest to newest
	for _, d := range obj.(Deltas) {
		switch d.Type {
		case Sync, Replaced, Added, Updated:
			s.cacheMutationDetector.AddObject(d.Object)
			if old, exists, err := s.indexer.Get(d.Object); err == nil && exists {
				// indexer进行更新
				if err := s.indexer.Update(d.Object); err != nil {
					return err
				}

				isSync := false
				switch {
				case d.Type == Sync:
					// Sync events are only propagated to listeners that requested resync
					isSync = true
				case d.Type == Replaced:
					if accessor, err := meta.Accessor(d.Object); err == nil {
						if oldAccessor, err := meta.Accessor(old); err == nil {
							// Replaced events that didn't change resourceVersion are treated as resync events
							// and only propagated to listeners that requested resync
							isSync = accessor.GetResourceVersion() == oldAccessor.GetResourceVersion()
						}
					}
				}
				// processor进行distribute
				s.processor.distribute(updateNotification{oldObj: old, newObj: d.Object}, isSync)
			} else {
			// indexer进行添加
				if err := s.indexer.Add(d.Object); err != nil {
					return err
				}
				s.processor.distribute(addNotification{newObj: d.Object}, false)
			}
		case Deleted:
			// indexer进行删除
			if err := s.indexer.Delete(d.Object); err != nil {
				return err
			}
			s.processor.distribute(deleteNotification{oldObj: d.Object}, false)
		}
	}
	return nil
}
```

- `listener`：在`processor`的时候创建，它的作用是：将`obj`对象分发至注册的`add/update/delete handles` ，它有两个方法`run\pop`

```go
// k8s.io/client-go/tools/cache/shared_informer.go
func (p *sharedProcessor) run(stopCh <-chan struct{}) {
	func() {
		p.listenersLock.RLock()
		defer p.listenersLock.RUnlock()
		for _, listener := range p.listeners {
			p.wg.Start(listener.run)
			p.wg.Start(listener.pop)
		}
		p.listenersStarted = true
	}()
	<-stopCh
	p.listenersLock.RLock()
	defer p.listenersLock.RUnlock()
	for _, listener := range p.listeners {
		close(listener.addCh) // Tell .pop() to stop. .pop() will tell .run() to stop
	}
	p.wg.Wait() // Wait for all .pop() and .run() to stop
}
```

- run是用来处理`notification`给注册的`handlers`
- `pop`是用来监听`addChannel`里面的`notification`，交由`run`来处理；

### Obj流转图

![k8s delta obj](/img/k8s/20210105095616.jpg)

- 红色的箭头即为`obj`的流转过程
- 最上面的`client\factory\handle`即为开发人员的操作过程；初始化创建等；

### 总结

- `apiserver`是`k8s`的主要入口，所有的操作都是由`ApiServer`来执行的；
- 通过`Informer`的处理，大大提升了`k8s`的扩展性，这也就衍生出了`Operator`的开发框架，像 [operator-framework](https://github.com/operator-framework)
- `FIFO queue`保证了消息的缓冲，大大提高了运行的性能；



### 参考

- [腾讯的一个小哥博客，写的非常好](https://www.luozhiyun.com/archives/391)