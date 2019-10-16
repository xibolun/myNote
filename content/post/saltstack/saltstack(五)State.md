---
date :  "2019-10-15T14:34:29+08:00" 
title : "SaltStack(五)State" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

### [State](https://docs.saltstack.com/en/latest/ref/states/index.html)

state是一个描述性文件，类似puppet的脚本，ansible的playbook，描述着需要配置/文件/软件/服务等的最终状态

#### 格式

```yaml
target_a:                         # ID declaration
  state_a:                        # State declaration
    - state_func_a: some_value    # function declaration
    - state_func_b: some_value    # ...
    - state_func_c: some_value
    - require:                    # requisite declaration
      - pkg: xxx                  # requisite reference
      - file: xxx/xxx.xx
  state_b:                        # Support multiple states
```

- [all_state](https://docs.saltstack.com/en/latest/ref/states/all/index.html)
- [声明state](http://docs.saltstack.cn/ref/states/highstate.html#state-declaration)

#### 实战安装vim

创建`/srv/salt/top.sls`

```shell
# /srv/salt/top.sls
base:
  '*':
    - tool
```

创建`/srv/salt/tool.sls`

```shell
# /srv/salt/tool.sls
tool:
  pkg.installed:
   - name: vim-common
```

执行

```shell
➜  salt sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' state.highstate 
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
----------
          ID: tool
    Function: pkg.installed
        Name: vim-common
      Result: True
     Comment: All specified packages are already installed
     Started: 09:02:43.874748
    Duration: 283.067 ms
     Changes:   

Summary for AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6
------------
Succeeded: 1
Failed:    0
------------
Total states run:     1
Total run time: 283.067 ms
```

查看结果

```shell
➜  salt sudo salt 'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6' cmd.run 'rpm -qa | grep vim'
AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6:
    vim-minimal-7.4.160-5.el7.x86_64
    vim-filesystem-7.4.629-6.el7.x86_64
    vim-common-7.4.629-6.el7.x86_64
```

或者在minion端执行

```shell
[root@minion2 ~]# salt-call state.highstate 
```

#### [Jinjia2](http://jinja.pocoo.org/docs)

实际在执行过程当中，不同的操作系统安装的包也不尽相同，需要在state文件里面加入相应的判断逻辑；

比如Fedora系统当中是 `httpd` ，但是在Debian/Ubuntu 却是 `apache2`；

所以需要使用jinjia模板进行一些简单判断，如下：

```yaml
# /srv/salt/webserver.sls
webserver:
  pkg.installed:
    - name: {% if grains['os_family'] =='RedHat' %} httpd {% elif grains['os_family']=='Arch' %} apache2 {% endif %}
```

也可以借助`grains`和`pillar`里面的变量数据，因为本质上就是数据存储结构；

```yaml
apache:
  pkg.installed:
    - name: {{ pillar['pkgs']['apache'] }}
```

#### 实战部署httpd服务

```yaml
# /srv/salt/webserver.sls
webserver:         
  pkg.installed:
    - name: {% if grains['os_family'] =='RedHat' %} httpd {% elif grains['os_family']=='Arch' %} apache {% endif %}
    
httpd.service:
  service.running:
    - require:
      - pkg: httpd
      
/var/www/index.html:
  file: 
    - managed
    - source: salt://webserver/index.html
    - require: 
      - pkg: httpd
```

> 1. managed的source当中的全路径为： /srv/salt/webserver/index.html，使用了salt协议，所以需要去掉前缀路径
>
> 2. 怎么知道哪个state下面有哪些function的参数
>    - https://docs.saltstack.com/en/latest/ref/states/all/index.html

### 其他用法

- [模板、继承、包含、watch、多环境等](http://docs.saltstack.cn/topics/tutorials/states_pt3.html)