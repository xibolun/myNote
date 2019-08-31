---
date :  "2019-05-14T11:09:22+08:00" 
title : "Go语言实战(五)Go语言的类型系统" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### 接口

- [interface demo](https://gobyexample.com/interfaces) 一个很入门的demo

### 嵌套类型

- 内部类型的方法可以提升到外部类型来调用

```
type user struct {
	name  string
	email string
}

func (u *user) EchoHello() {
	fmt.Println("hello ")
}

type admin struct {
	user
	level string
}

func TestPolymorphic(t *testing.T) {
	ad := admin{
		user: user{
			name:  "john",
			email: "john@163.com",
		},
		level: "super",
	}

	ad.EchoHello()
}
```

- 如何unmashal复合类型的结构体？

```
// BizYamlData Biz层配置的yaml文件解析
type BizYamlData struct {
	Basic    `yaml:",inline"`
	Methods  []*BizYamlMethod `json:"methods" yaml:"methods"`
	Entities []*Entity        `json:"entities" yaml:"entities"`
}
```



### 公有or私有

- gowc，大写字母为公有，公有变量，函数可以被其他不同的包所引用；而私有的变量和函数只能在本包下使用，这样约定可以省略关键字；像Java需要声明`private` 或`public`来区分到底是公有还是私有

