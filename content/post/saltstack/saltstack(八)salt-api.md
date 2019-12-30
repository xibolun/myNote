---
date :  "2019-10-30T16:37:18+08:00" 
title : "SaltStack(八)salt-api" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

## salt-api

### 环境搭建

`salt-api`使用 [rest_chrrypy](https://docs.saltstack.com/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html#a-rest-api-for-salt) 来提供restful服务，同时支持`http`和`https`两种模式

#### 安装`salt-api`

```shell
yum install salt-api  ## 安装时会将 CherryPy依赖安装上
```

#### 生成`ssl`证书

```
yum install pyOpenSSL 
salt-call --local tls.create_self_signed_cert
```

生成的证书位于`/etc/pki/tls/`下

```shell
/etc/pki/tls/certs/localhost.crt
/etc/pki/tls/certs/localhost.key
```

#### 添加配置

使用API接口在调用的时候，本质上还是需要`salt-master`去执行命令，所以需要将`salt-api`的服务配置放在`salt-master`里面，`touch /etc/salt/master.d/salt-api.conf`，添加如下配置

```shell
external_auth:
  pam:
    salt:  ## 本机ssh的用户名和密码
      - .*
rest_cherrypy:
  port: 8000
  host: 0.0.0.0
  disable_ssl: True  ## 是否关闭ssl，关闭后则使用http协议
  ssl_crt: /etc/pki/tls/certs/localhost.crt
  ssl_key: /etc/pki/tls/certs/localhost.key
```

说明

- `external_auth`(eAuth)是一种认证机制，可以使用扩展的`PAM`或`LDAP`。[salt-eAuth使用](https://docs.saltstack.com/en/latest/topics/eauth/index.html)
  - PAM(Pluggable authentication module)，*nix系统用户和程序之间的安装验证机制
  - LDAP(Lightweight Directory Access Portocol)，轻型目录访问协议，可以用于各样的密码管理

#### 启动

修改完配置文件后需要重启salt-master

```
systemctl restart salt-master.service
systemctl start salt-api.service
```

### 接口列表

[rest url reference](https://docs.saltstack.com/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html#id16)

申请token

```shell
curl  http://localhost:8000/login  -H "Accept: application/json"  -d username=salt   -d password=xxxxx   -d eauth=pam 

{"return": [{"perms": [".*"], "start": 1577690950.168191, "token": "416016368cf695aad0b281e3b41f52b0ccd565b1", "expire": 1577734150.168192, "user": "salt", "eauth": "pam"}]}
```

拿着申请过来的token，去请求其他的接口，需要在`Header`当中添加为`X-Auth-Token`

```
curl -i http://localhost:8000/ -H "Accept: application/json"  -H "X-Auth-Token: 416016368cf695aad0b281e3b41f52b0ccd565b1" -d client='local' -d tgt='*' -d fun="cmd.run" -d arg="uname -a"
```

