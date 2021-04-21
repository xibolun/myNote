---
date :  "2019-05-11T22:35:59+08:00" 
title : "Go语言实战(四)数组、切片、映射" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true
---

## 第4章 数组、切片、映射

### 数组

- 长度固定，内存连续
- 声明一个数组

```go
var arr [5]int
arr :=[...]int{10,20,30,40,50}
arr :=[5]int{10,20,30,40,50}
```

- 指针数组

```go
sp := [3]*string{new(string), new(string), new(string)} //使用new(type)的方式来初始化对象
*sp[0] = "red" // *sp[0]指针的引用
*sp[1] = "blue"
*sp[2] = "green"
```

- 复制数组的时候需要长度和类型都保持一致
- 数组在做为入参的时候因copy数组消耗比较大，所以一般传递的时候都会传递指针对象

### 切片

- 切片当中的容量与长度的概念是什么？
- 切片分为三块，头部指针，长度、容量，所以在64位架构设备上是24字节，所以做为参数传递或者复制开销小
- 空切片与nil切片的不同在于指针对象是否为nil
- 切片是动态增长的，可以自动增长和缩小；增长需要使用 `append ` 来实现
- append出来的切片会与原切片共享底层数组

```
a := []byte("ba")

a1 := append(a, 'd')
a2 := append(a, 'g')

fmt.Println(string(a1)) // bag
fmt.Println(string(a2)) // bag
```

- 初始化切片

```go
slice := make([]int, 5, 3)  // 长度不能大于容量

sl := make([]int, 3, 5)
fmt.Println(len(sl))  //3
fmt.Println(cap(sl))  //5

sl := make([]int,2)  // 初始化了两个0值的切片；长度和容量都为2
sl := make([][]interface) // 初始化一个interface数组的切片
```

- 切片截取

```go
origin := []int{10, 20, 30, 40, 50}
current := origin[1:3]
// 容量: cap(origin)-1, 长度: 3-1
fmt.Printf("current len %d, cap %d, value %v\n", len(current), cap(current), current)
// current 与 origin 共享了一套数组，所以值会被连动修改
current[1] = 35
fmt.Printf("current len %d, cap %d, value %v\n", len(current), cap(current), current)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

输出
current len 2, cap 4, value [20 30]
current len 2, cap 4, value [20 35]
origin len 5, cap 5, value [10 20 35 40 50]
```

- append出来的新元素，容量会增长2倍，注释容量的输出

```go
origin := []int{10, 20, 30, 40, 50}
current := append(origin, 60)

fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)
fmt.Printf("current len %d, cap %d, value %v\n", len(current), cap(current), current)

//origin len 5, cap 5, value [10 20 30 40 50]
//current len 6, cap 10, value [10 20 30 40 50 60]
```

```go
var origin []int
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

origin = append(origin, 2)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

origin = append(origin, 7)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

origin = append(origin, 1)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

origin = append(origin, 3)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

origin = append(origin, 8)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)

origin = append(origin, 4)
fmt.Printf("origin len %d, cap %d, value %v\n", len(origin), cap(origin), origin)
//origin len 0, cap 0, value []
//origin len 1, cap 1, value [2]
//origin len 2, cap 2, value [2 7]
//origin len 3, cap 4, value [2 7 1]
//origin len 4, cap 4, value [2 7 1 3]
//origin len 5, cap 8, value [2 7 1 3 8]
//origin len 6, cap 8, value [2 7 1 3 8 4]
```


- 第三个索引的作用

```go
origin := []string{"Apple", "Orange", "Plum", "Banana", "Grape"}

// 引入第三个索引进行创建切片
// 长度为3-2，容量为4-2
current := origin[2:3:4]

fmt.Printf("current len %d, cap %d, value %v\n", len(current), cap(current), current)
//current len 1, cap 2, value [Plum]
```

- range是copy一个属性，而不是原有属性

```go
origin := []string{"Apple", "Orange", "Plum", "Banana", "Grape"}
for i, v := range origin {
	fmt.Printf("index: %d, value: %s, value_point %v\n", i, v, &v)
}
//	value的指针地址都是同一个
//index: 0, value: Apple, value_point 0xc00004d110
//index: 1, value: Orange, value_point 0xc00004d110
//index: 2, value: Plum, value_point 0xc00004d110
//index: 3, value: Banana, value_point 0xc00004d110
//index: 4, value: Grape, value_point 0xc00004d110
```

- 数据若定义为指针，请小心；数组的内部是共享数据对象

```go

func TestAppend2(t *testing.T) {
	src := []int{1, 2, 3, 4, 5}

	// 输出55555
	for _, p := range copySlicePoint(src) {
		fmt.Print(*p)
	}

	fmt.Println()
	
	// 输出12345
	for _, p := range copySlice(src) {
		fmt.Print(p)
	}
}

func copySlicePoint(src []int) []*int {
	var dst2 []*int
	for _, i := range src {
		dst2 = append(dst2, &i)
	}
	return dst2
}

func copySlice(src []int) []int {
	var dst2 []int
	for _, i := range src {
		dst2 = append(dst2, i)
	}
	return dst2
}
```

`copySlicePoint`函数的操作过程与下面是一致的

```go
func copySlicePoint2(src []int) []*int {
	var dst2 []*int
	var j *int
	for _, i := range src {
		j = &i
		dst2 = append(dst2, j)
	}
	return dst2
}
```

### Map

- [go-maps-in-action](https://blog.golang.org/go-maps-in-action): 官方文档，讲的很透
- Key不能使用slice和func，不能使用==号进行判断这种衡量方式比较清奇
- map需要进行初始化使用

```
	var mapA map[string]string
	mapA["name"] = "zhangsan"  // 空指针异常
```

- working with map

```go
	mapA := make(map[string]string)
	mapA["name"] = "zhangsan"
	mapA["age"] = "10"
	mapA["address"] = "浙江杭州"
	mapA["company"] = "中科院"

	// map len
	t.Logf(" mapA length is %d", len(mapA))

	// get value
	name := mapA["name"]
	t.Logf("name is %s", name)

	// is exist
	age, ok := mapA["age"]
	t.Logf("age value is exist? %t, value is %s", ok, age)

	// delete one
	delete(mapA, "company")
	t.Logf("mapA %v", mapA)

	// loop
	for k, v := range mapA {
		t.Logf(" k: %s, v : %s", k, v)
	}
```

- map是线程不安全的，所以并发的时候需要使用[sync.RWMutex](https://golang.org/pkg/sync/#RWMutex).