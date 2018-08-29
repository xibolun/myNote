+++
date = "2018-07-19T20:39:43+08:00" title = "go规范及组件" categories = ["技术文章"] tags = ["go"] toc = true
+++

### 规范 ###

#### 命名规范

- 包名是小写单词，不应该有下划线或混合大小写，保持简洁，不要过早考虑包名冲突
- 使用驼峰而非下划线来命名函数或者变量

### GO组件使用注意 ###

  * [chi](https://github.com/go-chi/chi)
  * [hclog](https://github.com/hashicorp/go-hclog)
  * [dep](https://studygolang.com/articles/10589)

#### cli

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



