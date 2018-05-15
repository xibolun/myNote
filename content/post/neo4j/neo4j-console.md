+++
date = "2018-05-02T11:29:18+08:00" title = "neo4j控制台" categories = ["技术文章"] tags = ["neo4j"] toc = true
+++

## console内经

### 指令

- :play sysinfo：查看系统信息
- :help ——查看帮助
- :help commands——查看指令
- :help server——查看服务器相关指令



### 接口

修改密码

```
curl -H "Content-Type: application/json" -XPOST -d '{"password":"new password"}' -u neo4j:neo4j http://localhost:7474/user/neo4j/password
```

