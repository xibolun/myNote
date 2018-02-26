+++
date = "2018-02-02T10:13:59+08:00" title = "React--Redux学习" categories = ["技术文章"] tags = ["react"] toc = true
+++

### 为什么要使用Redux
- 某个组件要共享
- 某个组件要改变全局的状态
- 某个组件状态发生变化了，另外的组件也要变化
- 某个组件的状态要在各个地方拿到
- 短小精悍，只有2k
- 不仅仅支持react，还支持其他的库

### Redux核心思想
- Web是一个状态机，视图与状态一一对应
- 所有的状态都保存在一个对象里面(Store)

### 三大原则 

- 单一数据源
  - 所有的应用数据都保存在store当中
  - store的结构是一个大json

- 只读state
  - 要想改变state就是发dispatch
- reducer操作state
  - 利用reducer去action state的状态
  
### 一个demo

### 问题列表 ###
- 一个reducer里面有多个函数，怎么知道走的哪个函数的方法，同一个类型的action可能由多个函数来处理
- state里面的数据是什么样子的；

