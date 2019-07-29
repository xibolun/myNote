---

date :  "2017-12-14T23:36:24+08:00" 
title : "MongoDB高级学习" 
categories : ["技术文章"] 
tags : ["Mongo"] 
toc : true
---


## execute JS

创建test.js文件，录入以下文字

```js
printjson(db.adminCommand('listDatabases'));
printjson(db.getCollectionNames());
printjson(pwd());
```

执行js

```shell
mongo --quiet test.js
mongo test.js
mongo localhost:27017/test test.js
```

- 可以指定数据库连接和库名执行

- quiet的作用是执行的时候不输出相关的执行信息，shell版本、服务器版本等

- printjson是一个函数，将结果美化成json格式输出

- pwd()是一些常用的native函数列表  [native-methods ](https://docs.mongodb.com/manual/reference/method/js-native/#native-methods)

- db.adminCommand('listDatabases')与show dbs作用相同，是js脚本的写法，还有一些其他的改变见 [Differences Between Interactive and Scripted](https://docs.mongodb.com/manual/tutorial/write-scripts-for-the-mongo-shell/#differences-between-interactive-and-scripted-mongo)

### mongo CRUD

```javascript
conn = new Mongo("127.0.0.1:27017");
db = conn.getDB("xmdb-poc");

// insertMany();
//TODO  此项没有成功，需要再试一下
aggregation();

/**
 * insert one
 */
// let user = {"name":'pengganyu','age':10,'address':'hangzhou'};
// db.users.insert(user)


/**
 * insert multiple
 */
function insertMany(){
    let users = [{"name":'pengganyu','age':10,'address':'hangzhou'},
    {"name":'yezi','age':10,'address':'hangzhou'},
    {"name":'weixiang','age':10,'address':'hangzhou'}]
    
    db.users.insert(users);
}


/**
 * update 
 */
// db.users.updateOne({'age':10},{$set:{'age':20}});
// db.users.updateMany({'age':10},{$set:{'age':20}});

/**
 * delete
 */
// db.users.deleteOne({'age':20});
// db.users.deleteMany({'age':20});

/**
 * aggregation
 */
function aggregation(){
    printjson(db.users.aggregate([
        {$match:{'name':'pengganyu'}},
        {$group:{'_id':'$cust_id',total:{$sum:'age'}}}
    ]))
}

```

## MapReduce

```json
var result = db.cms_ci_class.mapReduce(
	function() {
		emit(this.name, 1)
	},
	function(key, values) {
		printjson(key + "--" + values);
		return Array.sum(values)
	}, {
		query: {},
		out: "hell"
	}
);

printjson(result);
```

```
{
        "result" : "hell",
        "timeMillis" : 9,
        "counts" : {
                "input" : 135,
                "emit" : 135,
                "reduce" : 0,
                "output" : 135
        },
        "ok" : 1
}
```



## 参考 

[write-scripts](https://docs.mongodb.com/manual/tutorial/write-scripts-for-the-mongo-shell/#write-scripts-for-the-mongo-shell)

