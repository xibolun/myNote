---

date :  "2018-07-19T20:39:43+08:00" 
title : "go规范及组件" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### 规范 ###

#### 命名规范

- 包名是小写单词，不应该有下划线或混合大小写，保持简洁，不要过早考虑包名冲突
- 使用驼峰而非下划线来命名函数或者变量
- 接口名称必须是er为后缀

### GO组件使用注意 ###

  * [awesome-go](https://github.com/avelino/awesome-go)
  * [chi](https://github.com/go-chi/chi)
  * [hclog](https://github.com/hashicorp/go-hclog)
  * [dep](https://studygolang.com/articles/10589)

#### urfave/cli

- github: [cli](https://github.com/urfave/cli)
- version字段默认flag为v,当我想定义一下-v, verbose的时候是会提示被重复的，修改默认的versionFlag即可；官网的README.md里面也有提及

```
	cli.VersionFlag = cli.BoolFlag{
		Name:  "V, version",
		Usage: "print only the version",
	}
```

- BoolFlag：若添加了一些flag，则其值为true，若不添加，值为false
- Flag当中的Destination可以将参数对应的value拿到
- 通过Args可以拿到命令行里面入参信息

```
func FileActions(ctx *cli.Context) error {
	args := ctx.Args()
	argsLen := len(args)

	target := args.Get(0)
	srcFile := args.Get(1)
	destFile := args.Get(2)
}

```

#### beego ####

##### httplib #####

httplib是beego的一个包，里面有restful相关的方法，问题如下：

``` go
package handler

func TestUpdateEntityIdByHostId(t *testing.T) {
    // queryParam参数
	postRequest := httplib.Put("http://localhost:6868/host/entity")
	postRequest.Param("hostId", "23143243214").Param("entityId", "34134123")
	fmt.Println(postRequest)
	req, err := postRequest.String()
    ....

}

```


``` go

    //取pathVariable方法
	r.URL.Query().Get("hostId") // 此种方法只能取pathVariable
   
    //取QueryParam参数方法
    r.ParseForm()   // 若要取queryParam，必须先parseForm一下，然后才能拿到具体数据
	r.Form.Get("hostId") // 发现此方法有时候取不到值，反而Query可以使用
	r.URL.Query().Get("hostId")
    
    //取QueryParam参数方法
    r.FormValue("hostId")
    
    //取body当中参数方法
    bytes, err := ioutil.ReadAll(r.Body)   //将bytes转成json即可
    
```




### urfave/cli ###

#### 一个bug ####
[https://github.com/urfave/cli/issues/355](issues/355)

#### 如何生成help和命令flag ####
#### 如何输出格式 ####
#### 如何输出色彩 ####
[bash_color](https://misc.flogisoft.com/bash/tip_colors_and_formatting)


### cobra ###
- 支持json、table样式输出

### gorm

```
	err := model.GetDb().Table("act2_job_record").Pluck("id",&strs).Error
```

#### 关于gorm的一个问题
```go

```


```go

```



### gRPC

[gRPC实战](https://jergoo.gitbooks.io/go-grpc-practice-guide/content)

