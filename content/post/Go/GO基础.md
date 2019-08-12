---

date :  "2018-07-19T20:39:43+08:00" 
title : "go语言基础学习笔记" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

## GO语言基础
### 顺序编程 ###
#### 执行

- 必须在main package下面的main方法才可以运行

#### 运算符 ####

- `&`  返回内存地址
- `*  `  返回指针变量

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

```
func TestArrayPoint(t *testing.T) {
	sp := [3]*string{new(string), new(string), new(string)}
	*sp[0] = "red"
	*sp[1] = "blue"
	*sp[2] = "green"

	for i, _ := range sp {
		fmt.Printf("point value %v,real value %s\n", sp[i], *sp[i])
	}
}
```



#### iota ####

##### string #####
  - len(str) :获取字符串的长度
  - s[i] : 取字符串s当中的某一条字符char类型
  - UTF8中3个字节
  - 默认值为"", bool为false, int为0 
  - %号转义  fmt.Sprintf("%%%s%s","hello") --> %hello%

###### stringbuild ######

``` go
// 线程不安全
func TestBufferWrite(t *testing.T) {
	strs := []string{"1", "2", "3", "4", "5", "6"}

	var buffer bytes.Buffer
	for _, str := range strs {
		buffer.WriteString(str)
	}

	fmt.Println(buffer.String())
}
```

#### 切片 ####

- cap
- len
- append
- append ... 当添加的元素也是一个切片的时候需要加...


``` go
func main() {
    s := make([]int, 5)
    s = append(s, 1, 2, 3)
    fmt.Println(s)    //  [0 0 0 0 0 1 2 3]

    s := make([]int, 0)
    s = append(s, 1, 2, 3)
    fmt.Println(s)//[1 2 3] //[1,2,3]
}


```

##### 切片截取性能测试 #####

``` go
func BenchmarkSliceCopy(b *testing.B) {
	b.ResetTimer()
	var a []int
	for i := 0; i < 10000000; i++ {
		a = append(a, i)
	}

	i := rand.Intn(1000000)

	copy(a[i:], a[i+1:])

	a = a[:len(a)-1]

	fmt.Println(len(a))

}

func BenchmarkSliceSplit(b *testing.B) {
	b.ResetTimer()
	var a []int
	for i := 0; i < 10000000; i++ {
		a = append(a, i)
	}
	i := rand.Intn(1000000)

	m := a[0:i]

	c := a[i+1:]

	a = append(m, c...)

	fmt.Println(len(a))

}

```

#### file ####
- file.writeString(string) 可以append file，不会覆盖文件

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

``` go
for i:=0;i<10;i++{
}

for i,x := range array{
}
```


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

``` go
[]byte(string)  // string to byte
```

```
func strConvert(str, typ string) (v interface{}, err error) {
   switch typ {
   case reflect.Int.String():
      v, err = strconv.ParseInt(str, 10, 0)
   case reflect.Int8.String():
      v, err = strconv.ParseInt(str, 10, 8)
   case reflect.Int16.String():
      v, err = strconv.ParseInt(str, 10, 16)
   case reflect.Int32.String():
      v, err = strconv.ParseInt(str, 10, 32)
   case reflect.Int64.String():
      v, err = strconv.ParseInt(str, 10, 64)
   case reflect.Uint.String():
      v, err = strconv.ParseUint(str, 10, 0)
   case reflect.Uint8.String():
      v, err = strconv.ParseUint(str, 10, 8)
   case reflect.Uint16.String():
      v, err = strconv.ParseUint(str, 10, 16)
   case reflect.Uint32.String():
      v, err = strconv.ParseUint(str, 10, 32)
   case reflect.Uint64.String():
      v, err = strconv.ParseUint(str, 10, 64)
   case reflect.Bool.String():
      v, err = strconv.ParseBool(str)
   case reflect.Float32.String():
      v, err = strconv.ParseFloat(str, 32)
   case reflect.Float64.String():
      v, err = strconv.ParseFloat(str, 64)
   case "reader":
      v = strings.NewReader(str)
   case "time":
      if strings.Contains(str, "CST") {
         v, err = time.Parse("2006-01-02 15:04:05 +0800 CST", str)
      }
   default:
      v = str
   }
   return
}
```

#### defer ####
- defer是先入后出，所以是先打印最后的
- defer会在return 之前被执行
``` go
func Test_defer(t *testing.T) {
	deferTest()
}

func deferTest() {
	defer fmt.Println("1")
	defer fmt.Println("2")
	defer fmt.Println("3")

	panic("error")
}

```

#### struct ####
- 两个结构体相等，必须得是参数名一样，顺序一样
- 若结构体当中存在map、slicen属性，则肯定不相等

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

### 其他库 ###
#### gofmt ####
[http://nickgravgaard.com/elastic-tabstops/](elastic-tabstops)


