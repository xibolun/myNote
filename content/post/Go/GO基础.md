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

#### byte ####
怎么样创建一个指定的bytes数组？println输出了一个byte数组，但是想创建出来，需要将其添加,

``` go
	rubyBytes := []byte{4, 8, 123, 15, 58, 9, 98, 111, 100, 121, 34, 2, 10, 1, 4, 8, 123, 9, 58, 10, 97, 103, 101, 110, 116, 73, 34, 10, 115, 104, 101, 108, 108, 6, 58, 6, 69, 84, 58, 11, 97, 99, 116, 105, 111, 110, 73, 34, 8, 114, 117, 110, 6, 59, 6, 84, 58, 11, 99, 97, 108, 108, 101, 114, 73, 34, 15, 99, 108, 111, 117, 100, 45, 97, 99, 116, 50, 6, 59, 6, 84, 58, 9, 100, 97, 116, 97, 123, 15, 58, 9, 116, 121, 112, 101, 73, 34, 11, 115, 99, 114, 105, 112, 116, 6, 59, 6, 84, 58, 9, 117, 115, 101, 114, 73, 34, 9, 114, 111, 111, 116, 6, 59, 6, 84, 58, 12, 99, 111, 109, 109, 97, 110, 100, 73, 34, 16, 115, 99, 114, 105, 112, 116, 58, 47, 116, 109, 112, 6, 59, 6, 84, 58, 13, 102, 105, 108, 101, 110, 97, 109, 101, 73, 34, 8, 116, 109, 112, 6, 59, 6, 84, 58, 12, 99, 111, 110, 116, 101, 110, 116, 73, 34, 13, 90, 87, 78, 111, 98, 119, 61, 61, 6, 59, 6, 84, 58, 11, 98, 97, 115, 101, 54, 52, 84, 58, 11, 112, 97, 114, 97, 109, 115, 73, 34, 0, 6, 59, 6, 84, 58, 15, 115, 99, 114, 105, 112, 116, 84, 121, 112, 101, 73, 34, 9, 66, 97, 115, 104, 6, 59, 6, 84, 58, 19, 112, 114, 111, 99, 101, 115, 115, 95, 114, 101, 115, 117, 108, 116, 84, 58, 16, 101, 110, 118, 105, 114, 111, 110, 109, 101, 110, 116, 73, 34, 0, 6, 59, 6, 84, 58, 13, 115, 101, 110, 100, 101, 114, 105, 100, 73, 34, 15, 99, 108, 111, 117, 100, 45, 97, 99, 116, 50, 6, 58, 6, 69, 84, 58, 14, 114, 101, 113, 117, 101, 115, 116, 105, 100, 73, 34, 46, 97, 99, 116, 50, 45, 102, 99, 53, 100, 56, 57, 54, 54, 45, 102, 54, 53, 53, 45, 56, 51, 101, 102, 45, 97, 53, 56, 51, 45, 56, 51, 97, 53, 50, 48, 99, 48, 97, 101, 48, 102, 6, 59, 7, 84, 58, 11, 102, 105, 108, 116, 101, 114, 123, 7, 73, 34, 10, 97, 103, 101, 110, 116, 6, 59, 7, 84, 91, 6, 73, 34, 10, 115, 104, 101, 108, 108, 6, 59, 7, 84, 58, 15, 99, 111, 108, 108, 101, 99, 116, 105, 118, 101, 73, 34, 16, 109, 99, 111, 108, 108, 101, 99, 116, 105, 118, 101, 6, 59, 7, 84, 59, 10, 73, 34, 16, 109, 99, 111, 108, 108, 101, 99, 116, 105, 118, 101, 6, 59, 7, 84, 58, 10, 97, 103, 101, 110, 116, 73, 34, 10, 115, 104, 101, 108, 108, 6, 59, 7, 84, 58, 13, 99, 97, 108, 108, 101, 114, 105, 100, 73, 34, 20, 99, 101, 114, 116, 61, 99, 108, 111, 117, 100, 45, 97, 99, 116, 50, 6, 59, 7, 84, 58, 8, 116, 116, 108, 105, 2, 16, 14, 58, 12, 109, 115, 103, 116, 105, 109, 101, 108, 43, 7, 101, 103, 111, 93, 58, 9, 104, 97, 115, 104, 73, 34, 37, 49, 57, 57, 51, 101, 98, 98, 52, 56, 97, 53, 101, 49, 49, 98, 97, 57, 102, 100, 48, 57, 56, 49, 53, 99, 102, 102, 101, 100, 55, 49, 102, 6, 59, 7, 70}

```

#### iota ####

##### string #####
  - len(str) :获取字符串的长度
  - s[i] : 取字符串s当中的某一条字符char类型
  - UTF8中3个字节
  - 默认值为"", bool为false, int为0 
  - %号转义  fmt.Sprintf("%%%s%s","hello") --> %hello%

-  [关于TrimRight的一个问题](https://groups.google.com/forum/#!topic/golang-nuts/WAItFEvrhmU)

  ```go
  	str := "\"\"aa233aa\""
  	fmt.Printf("Trim : %s\n", strings.Trim(str, "aa"))
  	fmt.Printf("TrimSuffix : %s\n", strings.TrimSuffix(str, "aa"))
  	fmt.Printf("trim : %s\n", strings.Trim("aa,bb,cc,dd", ","))
  	fmt.Printf("TrimLeft : %s\n", strings.TrimLeft(str, "aa"))
  	fmt.Printf("TrimRight : %s\n", strings.TrimRight(str, "aa"))
  	fmt.Printf("trim : %s\n", strings.Trim(str, "\""))
  
  
  	// TrimRight会截断掉给出的cutset所有的组合，以下TrimRigth都只输出A
  	// 官方解释：TrimRight returns a slice of the string s, with all trailing Unicode code points     contained in cutset removed.
  
  	// To remove a suffix, use TrimSuffix instead.
  	fmt.Printf("TrimRigth: %s\n", strings.TrimRight("A06-09~06", "-09~06"))
  	fmt.Printf("TrimRigth: %s\n", strings.TrimRight("A-9-09~06", "-09~06"))
  	fmt.Printf("TrimRigth: %s\n", strings.TrimRight("A9-09~06", "-09~06"))
  	fmt.Printf("TrimRigth: %s\n", strings.TrimRight("A~9-09~06", "-09~06"))
  	fmt.Printf("TrimRigth: %s\n", strings.TrimRight("A69-09~06", "-09~06"))
  	fmt.Printf("TrimSuffix: %s\n", strings.TrimSuffix("A06-09~06", "-09~06"))
  ```

  

###### stringbuilder ######

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


