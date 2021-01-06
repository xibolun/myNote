---

date :  "2020-03-17T17:58:41+08:00" 
title : "k8s——Operator开发" 
categories : ["k8s"] 
tags : ["k8s"] 
toc : true
description: k8s operator
---

## Operator

关于`Operator`的作用就略过，官方介绍有，下面是自己实战的一个过程；

### 实战过程

#### 下载安装

```shell
✗ brew install operator-sdk
```

#### 初始化项目

固定在某一个gopath下面，这样mod文件的依赖都会存到pkg下面，后续初始化速度就会比较快；

```shell
✗ mkdir $GOPATH/src/mySrv
✗ operator-sdk init --domain idcos.com --license apache2 --owner "Peng Ganyu"
Writing scaffold for you to edit...
Get controller runtime:
$ go get sigs.k8s.io/controller-runtime@v0.7.0
Update go.mod:
$ go mod tidy
Running make:
$ make
go: creating new go.mod: module tmp
Downloading sigs.k8s.io/controller-tools/cmd/controller-gen@v0.4.1
go: found sigs.k8s.io/controller-tools/cmd/controller-gen in sigs.k8s.io/controller-tools v0.4.1
/Users/admin/projects/go/src/mySrv/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
go fmt ./...
go vet ./...
go build -o bin/manager main.go
Next: define a resource with:
$ operator-sdk create api
```

执行完的后，会生成`Makefile`，这里面包含了编译、打镜像、运行等各个模块；还有其他的一些`crd`模板文件等；

#### 创建API

```shell
✗ operator-sdk create api --group=myapp --version=v1alpha1 --kind=MySrv
Create Resource [y/n]
y
Create Controller [y/n]
y
Writing scaffold for you to edit...
api/v1alpha1/mysrv_types.go
controllers/mysrv_controller.go
Running make:
$ make
/Users/admin/projects/go/src/mySrv/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
go fmt ./...
go vet ./...
go build -o bin/manager main.go
```

`kind`必须得是大写开头的驼峰；会生成一个`api`、`controller`、`crd`等

```shell
        api/
        config/crd/
        config/rbac/mysrv_editor_role.yaml
        config/rbac/mysrv_viewer_role.yaml
        config/samples/
        controllers/
```

#### 修改types

`api`里面有一个`mysrv_types.go`文件

修改自己的`MySrvSpec`结构体，看看放置哪些属性

```go
// MySrvSpec defines the desired state of MySrv
type MySrvSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	Port int `json:"port"`
	Name string `json:"name"`
}

// MySrvStatus defines the observed state of MySrv
type MySrvStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file
	Status string `json:"status"`
}
```

生成代码

```shell
✗ make generate
```

生成配置文件

```shell
✗ make manifests
```

```shell
        config/crd/bases/
        config/rbac/role.yaml
```

#### 修改Reconcile

`operator`将所有的逻辑都集中在`controllers/mysrv_controller.go`当中的`Reconcile`当中；

你可以用`r.Client`查询、修改、删除等各项的操作；也可以在此进行业务逻辑的校验、处理等；

以下是写了一个查询是否存在的逻辑；

```go
func (r *MySrvReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := r.Log.WithValues("mysrv", req.NamespacedName)

	// your logic here
	mySrv := &myappv1alpha1.MySrv{}
	if err := r.Client.Get(context.TODO(), req.NamespacedName, mySrv); err != nil {
		log.Error(err, "client get result fail")
		return reconcile.Result{}, nil
	}

	if mySrv.DeletionTimestamp == nil {
		return reconcile.Result{}, nil
	}

	log.Info("get mysrv, %v", mySrv)

	return ctrl.Result{}, nil
}
```

#### 运行

先创建自定义的`mySrv`

```
✗ kubectl create -f config/crd/bases/myapp.idcos.com_mysrvs.yaml
customresourcedefinition.apiextensions.k8s.io/mysrvs.myapp.idcos.com created
```

有两种运行方式，一种是通过远程`k8s`的配置连接运行；注册的`manager`会自动寻找配置文件进行连接；远程的乃是通过打包上传镜像，然后远程的`k8s`拉取镜像启动服务；

本地运行

```shell
✗ make run ENABLE_WEBHOOKS=false
/Users/admin/projects/go/src/mySrv/bin/controller-gen object:headerFile="hack/boilerplate.go.txt" paths="./..."
go fmt ./...
go vet ./...
/Users/admin/projects/go/src/mySrv/bin/controller-gen "crd:trivialVersions=true,preserveUnknownFields=false" rbac:roleName=manager-role webhook paths="./..." output:crd:artifacts:config=config/crd/bases
go run ./main.go
I0106 21:33:27.659679   14202 request.go:645] Throttling request took 1.046395137s, request: GET:https://10.0.4.175:6443/apis/admissionregistration.k8s.io/v1beta1?timeout=32s
2021-01-06T21:33:30.573+0800    INFO    controller-runtime.metrics      metrics server is starting to listen    {"addr": ":8080"}
2021-01-06T21:33:30.574+0800    INFO    setup   starting manager
2021-01-06T21:33:30.574+0800    INFO    controller-runtime.manager      starting metrics server {"path": "/metrics"}
2021-01-06T21:33:30.575+0800    INFO    controller-runtime.manager.controller.mysrv     Starting EventSource    {"reconciler group": "myapp.idcos.com", "reconciler kind": "MySrv", "source": "kind source: /, Kind="}
2021-01-06T21:33:30.676+0800    INFO    controller-runtime.manager.controller.mysrv     Starting Controller     {"reconciler group": "myapp.idcos.com", "reconciler kind": "MySrv"}
2021-01-06T21:33:30.676+0800    INFO    controller-runtime.manager.controller.mysrv     Starting workers        {"reconciler group": "myapp.idcos.com", "reconciler kind": "MySrv", "worker count": 1}
```

#### 添加资源

修改配置文件，添加Name和Port规格

```yaml
// config/samples/myapp_v1alpha1_mysrv.yaml
apiVersion: myapp.idcos.com/v1alpha1
kind: MySrv
metadata:
  name: mysrv-sample
spec:
  Name: CloudCMP
  Port: 80
```

```shell
✗ kubectl create -f config/samples/myapp_v1alpha1_mysrv.yaml
mysrv.myapp.idcos.com/mysrv-sample created
✗ kubectl get mySrv
NAME           AGE
mysrv-sample   12s
```

### 遇到的一些问题

#### init报错

请求mod文件请求不到，503异常

```shell
Downloading sigs.k8s.io/kustomize/kustomize/v3@v3.8.7
go get sigs.k8s.io/kustomize/kustomize/v3@v3.8.7: sigs.k8s.io/kustomize/kustomize/v3@v3.8.7: reading http://10.0.5.64:8080/sigs.k8s.io/kustomize/kustomize/v3/@v/v3.8.7.info: 503 Service Unavailable
make: *** [kustomize] Error 1
```

确保`goproxy`是否配置正确，因为国内的其他`proxy`服务未同步它的`mod`文件配置，因为我设置的`proxy`为内网的地址，请求不到`https://goproxy.cn`

```shell
➜  ~ go env | grep GOPROXY
GOPROXY="https://goproxy.cn,direct"
```

#### 无法找到配置信息

有可能你的`k8s`认证配置文件，不在`~/.kube/config`目录，查了一下源码`operator-sdk`可以通过配置环境变量的方式配置

```go
export KUBECONFIG=~/.kube/config
```

```go
	// If the recommended kubeconfig env variable is not specified,
	// try the in-cluster config.
	kubeconfigPath := os.Getenv(clientcmd.RecommendedConfigPathEnvVar)
	if len(kubeconfigPath) == 0 {
		if c, err := loadInClusterConfig(); err == nil {
			return c, nil
		}
	}

```

#### make run报错

```shell
✗ make run
2021-01-06T17:03:59.308+0800    ERROR   controller-runtime.manager      Failed to get API Group-Resources       {"error": "Get \"https://10.0.4.175:6443/api?timeout=32s\": net/http: TLS handshake timeout"}
```

原因是我开了`proxy`代理，导致无法与远程的`k8s`服务器进行通讯，连`get pod`也无返回值



### 参考

- [operator-framework官方文档](https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/)