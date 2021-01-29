---

date :  "2021-01-29T16:44:02+08:00" 
title : "Istio—从源码看Sidecar注入原理" 
categories : ["istio"] 
tags : ["istio"] 
toc : true
description:  istio sidecar injector 原理
---

### Sidecar

问题：当创建一个`Pod`的时候，`Istio`需要对其进行观察，服务治理、信息采集等，这些操作都是通过`Envoy`处理的；那`Envoy`什么时候创建的呢？

在`k8s`当中一个`Pod`里面可以有多个`Container`，如果想要创建一个`Sidecar`，那最简单的思路便是把原来创建一个`Pod`的`Deployment`配置文件修改一下，再创建一个`Container`即可，这便是`Istio`注入的操作过程；

在单个`pod`的`deployment`创建的时候，我们添加一个拦截功能，“偷偷”修改掉`deployment`的配置即可完成这样的操作，这就需要用到`k8s`的 [admission controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-does-each-admission-controller-do)；

### 注入

#### 手工注入

从源码当中可以看到需要的参数信息

```shell
## istioctl/cmd/kubeinject.go
istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml \
    --injectConfigFile /tmp/inj-template.tmpl \
    --meshConfigFile /tmp/mesh.yaml \
    --valuesFile /tmp/values.json
```

按 [官方的文档](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#manual-sidecar-injection) 生成`inject-config.yaml`、`mesh-config.yaml`、`inject-values.yaml`，执行即可创建出来一个2个`Container`的`Pod`

```shell
 ~ kubectl get pod  -l app=sleep
NAME                    READY   STATUS    RESTARTS   AGE
sleep-8f795f47d-96gpd   2/2     Running   0          3h14m
```

这里面发生了什么呢？这个可以通过命令行工具生成一个`deployment.yaml`文件

```shell
$ istioctl kube-inject \
    --injectConfigFile inject-config.yaml \
    --meshConfigFile mesh-config.yaml \
    --valuesFile inject-values.yaml \
    --filename samples/sleep/sleep.yaml  > sleep_delpoyment.yaml
```

对比生成的文件和``samples/sleep/sleep.yaml`，可以看到对原`deployment`进行了以下的改动

- 添加`annotations`，`labels`

![istio-sidecar-sleep-diff](/img/istio/istio-sidecar-sleep-diff.jpg)

- 添加`istio-proxy`容器，添加代理，转发

![istio-sidecar-injector-istio-proxy](/img/istio/istio-sidecar-injector-istio-proxy.jpg)

- 添加`istio-init`容器：主要作用是创建`iptables`规则

![istio-sidecar-injector-istio-init](/img/istio/istio-sidecar-injector-istio-init.jpg)

#### 自动注入

[自动注入](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#automatic-sidecar-injection) 在官方文档里面写的比较清楚，主要步骤如下：

- 开启允许`istio`注入的`namespace`标签，主要对`default ns` 进行处理

```
$ kubectl label namespace default istio-injection=enabled
```

- 创建`Pod`即可

```
kubectl apply -f samples/sleep/sleep.yaml
```

这里面发生了什么事情呢？执行完上面的命令后，会进入`istio-pilot`的`/inject`请求当中；在`istiod`容器内部的日志当中可以看到如下的信息

![istio-pilot-inject-log](/img/istio/istio-pilot-inject-log.jpg)

在`istio-sidecar-injector`当中早早添加了配置如下，这个配置告诉了`k8s-apiserver`，会有如下的条件判断

- `namespace`的标签里面带有`istio-injection`
- 当`apiserver`当中存在`CREATE POD `时；
- 将此请求转发至`istiod serverice /inject`接口；

```shell
 ~ kubectl get  mutatingwebhookconfiguration istio-sidecar-injector -o yaml
webhooks:
- admissionReviewVersions:
  - v1beta1
  - v1
  clientConfig:
    caBundle: ......
    service:
      name: istiod
      namespace: istio-system
      path: /inject
      port: 443
  failurePolicy: Fail
  matchPolicy: Exact
  name: sidecar-injector.istio.io
  namespaceSelector:
    matchLabels:
      istio-injection: enabled
  objectSelector: {}
  reinvocationPolicy: Never
  rules:
  - apiGroups:
    - ""
    apiVersions:
    - v1
    operations:
    - CREATE
    resources:
    - pods
    scope: '*'
  sideEffects: None
  timeoutSeconds: 30
```

在启动容器`istiod`的时候会有一个`pilot-discovery`进程，这个便是`istio-pilot`的主进程

```shell
$ ps -aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
istio-p+     1  0.2  0.8 852068 132900 ?       Ssl  Jan26  11:26 /usr/local/bin/pilot-discovery discovery --monitoringAddr=:15014 --log_output_level=default:info --domain cluster.local --keepaliveMaxServerConnectionAge 30m
```

通过源码可以看到在`NewWebhook`的时候，已经添加了`/inject`的路由

```go
// NewWebhook creates a new instance of a mutating webhook for automatic sidecar injection.
func NewWebhook(p WebhookParameters) (*Webhook, error) {
   ......
   p.Mux.HandleFunc("/inject", wh.serveInject)
   p.Mux.HandleFunc("/inject/", wh.serveInject)
	.....
}
```

在`serverInject`的时候，会去解析请求信息`url path`、`content-type`是否为`application/json`、`body`是否为空等，若初步的校验没有问题，则会进入`webhook.inject`逻辑；

```go
//  pkg/kube/inject/webhook.go
func (wh *Webhook) inject(ar *kube.AdmissionReview, path string) *kube.AdmissionResponse {
  .......
	// Deal with potential empty fields, e.g., when the pod is created by a deployment
	podName := potentialPodName(&pod.ObjectMeta)
	if pod.ObjectMeta.Namespace == "" {
		pod.ObjectMeta.Namespace = req.Namespace
	}
  // 这个地方的日志信息便是上图日志打印的出处；
	log.Infof("Sidecar injection request for %v/%v", req.Namespace, podName)
	log.Debugf("Object: %v", string(req.Object.Raw))
	log.Debugf("OldObject: %v", string(req.OldObject.Raw))

	......
  // 获取 pod、deployment、注解等信息，下面就进行注入逻辑
	patchBytes, err := injectPod(params)
	......
	return &reviewResponse
}
```

注入逻辑也是比较清楚，即解析`oldPod`，再将`pod`配置进行组装，包括面提到的几个操作，修改`spec/label`、`spec/annotations`，添加`istio-proxy`、`istio-init`容器，组装出来新的`Pod`配置信息后，放入`http response`（`AdmissionResponse`）当中返回给`k8s-apiserver`，并对注入成功的的`Pod`累加计数；

```go
	reviewResponse := kube.AdmissionResponse{
		Allowed: true,
		Patch:   patchBytes,
		PatchType: func() *string {
			pt := "JSONPatch"
			return &pt
		}(),
	}
	totalSuccessfulInjections.Increment()
```

`k8s-apisever`拿到`response`后根据对应的配置信息创建`Pod`。

整体的流程图如下：

![istio-sidecar-inject-flow](/img/istio/istio-sidecar-inject-flow.jpg)

1. 首先注入`MutatingWebhookConfiguration`，配置`k8s-apiserver`创建`pod`时的转发规则
2. 执行创建命令，请求至`k8s-apisever`
3. `k8s-apiserver`转发`injecdt`至`pilot webhook`，对`pod`配置进行重组
4. 返回重组后的`AdmissionResponse`给`k8s-apiserver`
5. `k8s-apisever`根据`Response`当中的配置创建`sleep`、`istio-init`容器；

### 参考

- [istio sidecar-injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

