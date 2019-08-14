---
date :  "2019-08-13T15:04:36+08:00" 
title : "关于gorm的问题" 
categories : ["技术文章"] 
tags : ["Go"] 
toc : true
---

## 关于gorm的问题

### DB的search无法置空

下面是一个有问题的代码；大体逻辑是locatino表里面有PID，一级一级向上找父节点；第二次for循环的时候没有取到正常的结果，而是`record not found` ；原因是由于查询条件重叠了

```go
// GetLocationFullNameByID 根据指定ID返回位置的全路径名
func (repo *MySQLRepo) GetLocationFullNameByID(id uint) (name string, err error) {
	if id <= 0 {
		return "", nil
	}

	var loc model.Location
	for id > 0 {
    // 此处第二个for循环的sql会变成  where id = ? and id =?
		if err := repo.db.Model(&model.Location{}).Where("id = ?", id).Find(&loc).Error; err != nil {
			if err != gorm.ErrRecordNotFound {
				repo.log.Errorf("Query location by id(%d) error: %s", id, err.Error())
			}
			return "", err
		}
		if loc.PID > 0 {
			id = loc.PID
			name = loc.Name + "-" + name
		}
	}
	return strings.TrimRight(name, "-"), nil
}
```

看一下源码：

```go
func (s *DB) Model(value interface{}) *DB {
	c := s.clone()
	c.Value = value
	return c
}

func (s *DB) Where(query interface{}, args ...interface{}) *DB {
	return s.clone().search.Where(query, args...).db
}

func (s *DB) clone() *DB {
	db := DB{
		db:                s.db,
		parent:            s.parent,
		logger:            s.logger,
		logMode:           s.logMode,
		values:            map[string]interface{}{},
		Value:             s.Value,
		Error:             s.Error,
		blockGlobalUpdate: s.blockGlobalUpdate,
	}

	for key, value := range s.values {
		db.values[key] = value
	}

	if s.search == nil {
		db.search = &search{limit: -1, offset: -1}
	} else {
		db.search = s.search.clone()
	}

	db.search.db = &db
	return &db
}
```

> 从源码当中可以看到，不管是Model、Where还是其他的查询相关函数都使用了clone方法，而clone里面若原search不为nil，则进行叠加； [main.go](https://github.com/jinzhu/gorm/blob/master/main.go)

解决方法

```go
// GetLocationFullNameByID 根据指定ID返回位置的全路径名
func (repo *MySQLRepo) GetLocationFullNameByID(id uint) (name string, err error) {
	if id <= 0 {
		return "", nil
	}

	for id > 0 {
		var loc model.Location
		if err := repo.db.NewScope(nil).DB().Model(&model.Location{}).Where("id =?", id).Find(&loc).Error; err != nil {
			if err != gorm.ErrRecordNotFound {
				repo.log.Errorf("Query location by id(%d) error: %s", id, err.Error())
			}
			return "", err
		}
		if loc.PID >= 0 {
			id = loc.PID
			name = loc.Name + "-" + name
		}
	}
	return strings.TrimRight(name, "-"), nil
}
```

```go
// NewDB create a new DB without search information
func (scope *Scope) NewDB() *DB {
	if scope.db != nil {
		db := scope.db.clone()
		db.search = nil
		db.Value = nil
		return db
	}
	return nil
}
```

> 从源码当中可以看到从Scope里面New出来的DB，将search可以置空，因此就不会发生查询条件重复的问题

或者使用原生的sql机制

```go
// GetLocationFullNameByID 根据指定ID返回位置的全路径名
func (repo *MySQLRepo) GetLocationFullNameByID(id uint) (name string, err error) {
	if id <= 0 {
		return "", nil
	}

	for id > 0 {
		var loc model.Location
		if err := repo.db.Raw("select *  from locations where id  =? and deleted_at is null  ", id).Scan(&loc).Error; err != nil {
			if err != gorm.ErrRecordNotFound {
				repo.log.Errorf("Query location by id(%d) error: %s", id, err.Error())
			}
			return "", err
		}
		if loc.PID >= 0 {
			id = loc.PID
			name = loc.Name + "-" + name
		}
	}
	return strings.TrimRight(name, "-"), nil
}
```

看源码

```go
// Exec execute raw sql
func (s *DB) Exec(sql string, values ...interface{}) *DB {
	scope := s.clone().NewScope(nil)
	generatedSQL := scope.buildWhereCondition(map[string]interface{}{"query": sql, "args": values})
	generatedSQL = strings.TrimSuffix(strings.TrimPrefix(generatedSQL, "("), ")")
	scope.Raw(generatedSQL)
	return scope.Exec().db
}
```

> Exec的与NewScop的本质没有区别，都是使用NewScope进行操作