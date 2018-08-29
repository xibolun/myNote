+++
date = "2018-07-19T20:39:43+08:00" title = "go语言基础学习笔记" categories = ["技术文章"] tags = ["go"] toc = true
+++

## GO语言基础

### 顺序编程 ###

#### 执行

- 必须在main package下面的main方法才可以运行

#### 运算符 ####

- `& 返回内存地址
- ·* 返回指针变量

```go
func addRessFunc() {

	a := 1
	c := a
	b := &a
	*b = 2

	fmt.Println(&a, &b, &c)
	fmt.Println(&a, b, &c)
	fmt.Println(a, *b, c)
	fmt.Println(a, b, c)
}	
```

输出结果

```
0xc420084008 0xc420090018 0xc420084010
0xc420084008 0xc420084008 0xc420084010
2 2 1
2 0xc420084008 1
```

#### string ####

- len(str) :获取字符串的长度
- s[i] : 取字符串s当中的某一条字符char类型
- UTF8中3个字节
- 默认值为"", bool为false


#### 切片 ####

- cap
- len
- append
- append ... 当添加的元素也是一个切片的时候需要加...


#### map  ####
- var myMap map[string] PersonInfo  :声明一个map
- myMap = make(map[string] PersonInfo)  :创建一个map
- myMap = make(map[string] PersonInfo, 100)  :创建一个由容量的map
- myMap["1234"] = PersonInfo{"1", "Jack", "Room 101,..."}  :赋值
- delete(myMap, "1234") :删除元素
- value, ok := myMap["1234"] :获取元素值

#### switch  ####
- 没有break，默认break
- 使用fallthrough,当前case会紧跟着下一个case

#### loop ####
- 不支持while和do-while
- 支持break contiue
- JLoop


#### func ####
- 首字母小写为私有func，大写为公有func
- 不定参数 func add(args ....int)
- 若想要忽略某一个返回值可以使用 _ ;   a,_ :=func()
- 匿名函数，不带函数名的函数


#### 闭包 ####
- [ ]TODO

#### 错误处理 ####

#### 转换

```
Strings.NewReader(string)  // string to reader
bytes.NewReader([]byte)  // []byte to reader
```




### 面向对象编程 ###

#### 类型 ####
- 无this关键字，对象需要显式进行传递
- 若需要改变传入对象，则需要传入对象的指针 (a *Integer)

#### 调用形式

- 方法（可以满足接口）

```
func (n1 *NameAge) doSomething(n2 int) { /* */ }
```

- 函数

```
func doSomething(n1 *NameAge, n2 int) { /* */ }
```

