---
date :  "2019-10-20T23:01:23+08:00" 
title : "SaltStack(七)salt-ssh" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

### Salt-ssh

创建一个roster，类似`ansible`的`/etc/ansible/hosts`配置文件

```yaml
# /etc/salt/roster
10.0.2.7:
  host: 10.0.2.7
  user: root        
  passwd: Yunjikeji#123 
```

执行密码后第一次连接还需要输入确认，所以一般会将公钥发给指定的设备上面

```shell
➜  ~ sudo ssh-copy-id -i /etc/salt/pki/master/ssh/salt-ssh.rsa.pub root@10.0.2.7
```

执行命令

```shell
➜  ~ sudo salt-ssh '*' -r 'ls /tmp'   ## -r执行原生的命令
➜  ~ sudo salt-ssh '*' -r 'ls /tmp' --roster-file /tmp/roster  ## 指定roster文件执行
➜  ~ sudo salt-ssh '*' cmd.run 'ls /tmp' ## 可以调用salt的fun模块
➜  ~ sudo salt-ssh '*' cp.get_file salt://ping.sls /tmp  ## 调用cp.get_file模块下发文件
```

