---
date :  "2019-07-30T00:21:32+08:00" 
title : "Go template" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### Go Template

最近需要写一个代码生成工具，研究了一下template；golang有两个包， [html/template](https://golang.org/pkg/html/template/) 和 [text/template](https://golang.org/pkg/text/template/) 区别在于前者使用了一些转义

### 作用域

### 运算符

#### 循环

##### map循环

##### 数组循环

##### eq、if、or

##### 变量引用

```
{{$ref := .Basic}}
{{range $i,$v := .Methods}}
  ,
  {
    "category": "{{$v.Buttons}}",
    "category_name": "{{$v.Comment}}",
    "http_method": "{{$v.HttpMethod | ToGoTypeCamel}}",
    "url": "{{$ref.BaseURI}}{{$v.URL}}"
  }{{end}}
```

##### len的使用

```
{{ $length := len $v.CReq.Attrs }} {{if gt $length 0}}
```

##### function

定义function

```
func IsNil(v interface{}) bool {
	return v == nil
}
```
将function添加至template当中
```
	tplFunc := template.FuncMap{
		"ToGoTypeCamel": common.ToGoTypeCamel,
		"ToCamel":       common.ToCamel,
		"ToGinURL":      common.ToGinURL,
		"ToUpper":       strings.ToUpper,
		"IsNil":         common.IsNil,
	}

	tpl := template.Must(template.New(r.Name).Funcs(tplFunc).Parse(string(bytes)))
```

使用

```
{{if $v | IsNil}}{{end}}
```

#### 其他

- 如何去掉`range`、`if`等带来的回车？

把换行去掉，模板文件可能会比较丑一些
