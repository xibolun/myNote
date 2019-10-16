---
date :  "2019-07-30T00:15:33+08:00" 
title : "Ansbile学习" 
categories : ["技术文章"] 
tags : ["ansible"] 
toc : true
---

### 牛刀小试

1. 将ansible的ssh-pub添加至远程的服务器当中，建立ssh连接

2. 建立/etc/ansible/hosts文件，配置远程的服务器

   ```
   [hosts]
   10.0.106.2
   ```

3. 尝试执行 

   ```
   ➜  ~ ansible -u root -m  ping
   10.0.106.2 | SUCCESS => {
       "changed": false,
       "ping": "pong"
   }
   ```

### 配置

#### 配置文件次序

- `ANSIBLE_CONFIG` (一个环境变量)
- `ansible.cfg` (位于当前目录中)
- `.ansible.cfg` (位于根目录中)
- `/etc/ansible/ansible.cfg`
- 配置项列表说明：[ansbile.cfg](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)

#### 认证方式

ssh

```shell
ssh-keygen -t rsa
```

```shell
ssh-copy-id -i ~/.ssh/id_rsa.pub root@10.0.3.5
```

配置文件内置密码

```shell
[webservers]
10.0.3.5 ansible_ssh_pass='Yunjikeji#123' ansible_ssh_port=2222
10.0.2.1 ansible_ssh_pass='Yunjikeji#123' ansible_ssh_port=2222
```

还可以配置内置端口,用于配置容器化技术, `inventory`里面有许多的内置参数 [inventory-parameters](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#assigning-a-variable-to-one-machine-host-variables)

### 各模块说明

- adhoc：可以快速执行的一些命令，比如说查看rpm包、服务信息，文件权限等`-m`参数执行
- playbooks：ansible的配置、发布、编排语言，将你需要的配置改成目标即可
- invertory：主机信息配置文件，ansible通过读取此配置文件来获取到需要执行的目标机器，主机列表支持group和pattern
- Cobbler：ansible的一个插件，RHEL发版，管理DNS和DHCP网络的工具

#### Ad-hoc

ansible的模块，有各个公司、个人的支持，这也是ansible火起来的原因；比如ping、copy、shell、yum、user等

```shell
[root@cloudboot etc]# ansible-doc -l | wc -l
2114
```

下发文件

```
ansible webservers -m copy -a 'src=/tmp/cloudboot-server.conf dest=/tmp/cloudboot-server.conf'  -i inventory.cfg
```
shell模块使用； 查看nginx服务状态

```
ansible webservers -m shell  -a 'systemctl status nginx' -i inventory.cfg
```

ansible还做了命令的解析和处理
``` shell
~ ansible hosts -m shell -a 'rm -rf swagger.log' 
 [WARNING]: Consider using the file module with state=absent rather than running 'rm'.  If you need to use command because file is insufficient you can add 'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.
```

服务处理

```
ansible hosts -m service -a "name=nginx state=started" -u root
ansible hosts -m service -a "name=nginx state=stopped" -u root
```

#### facts

一个ansible的采集，类似setup模块

```
[root@cloudboot inventory]# ansible webservers -m setup -a 'filter=ansible_eth0' -i inventory.cfg  
10.0.2.1 | SUCCESS => {
    "ansible_facts": {
        "ansible_eth0": {                                                     
            "active": true,         
            "device": "eth0", 
            "ipv4": {           
                "address": "10.0.2.1",  
                "broadcast": "10.0.255.255", 
                "netmask": "255.255.0.0", 
                "network": "10.0.0.0"
            },      
            "macaddress": "52:54:00:e4:27:bd", 
            "module": "virtio_net", 
            "mtu": 1500, 
            "pciid": "virtio0", 
            "promisc": false, 
            "type": "ether"
        }
    }, 
    "changed": false
}
```

#### 其他

- role：一些连续操作的规范
- galaxy: [galaxy-ansible](https://galaxy.ansible.com/) 方便查询和分享role
- ansible-pull : 可以拉取配置中心的配置信息，然后用于下发操作  [clever-pull](https://github.com/ansible/ansible-examples/blob/master/language_features/ansible_pull.yml)

#### Playbook

ping-playbook.yml

```yaml
---
- hosts: webservers
  remote_user: root
  tasks:
    - name: test connection
      ping: 
    - name: status nginx
      shell: systemctl status nginx
```

执行命令

```shell
[root@cloudboot inventory]# ansible-playbook ping_playbook.yml -i inventory.cfg 

PLAY [webservers] ******************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [10.0.2.1]
ok: [10.0.3.5]

TASK [test connection] *************************************************************************************************************************************
ok: [10.0.3.5]
ok: [10.0.2.1]

TASK [status nginx] ****************************************************************************************************************************************
changed: [10.0.2.1]
changed: [10.0.3.5]

PLAY RECAP *************************************************************************************************************************************************
10.0.2.1                   : ok=3    changed=1    unreachable=0    failed=0   
10.0.3.5                   : ok=3    changed=1    unreachable=0    failed=0  
```

##### 命令其他参数

- 校验语法：`ansible-playbook ping_playbook.yml --syntax-check`
- 从第几个task开始执行： `ansible-playbook ping_playbook.yml -i inventory.cfg  --start-at-task 'status nginx''`
- playbook里有哪些参数：[playbooks_keywords](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#play)
- task里面有哪些参数：[task_keywords](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#task)
- 变量使用：[playbooks_variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#)

### 加密

```
[root@cloudboot inventory]# cat loop.yml 
---
- hosts: webservers
  gather_facts: false
  tasks: 
      - name: debug loops
        debug: 
[root@cloudboot inventory]# ansible-vault encrypt loop.yml 
New Vault password: 
Confirm New Vault password: 
Encryption successful
[root@cloudboot inventory]# cat loop.yml 
$ANSIBLE_VAULT;1.1;AES256
38306338326462323230316139366264303438613439613963653566633036383866333832663332
3264366536356135313739333866376431333339326536630a303863373633343133623266616461
63353832346630616130663339353637383464633962333737616439306665633465323661393630
3239646236363564370a393438396465643138393362326566383036653463363532636635653637
61313362633236306363636536333032633833616530626566636362393735346433353937393735
38393264316435356436636461363931356432396166613762373663323039363063313338623430
64646264336335383239363633353166666437643737313164396462316632666439646633666338
63636130636438333766313431346536653566653735646563343235303333356539633133653462
65613565633532336664663537613834623532363166643334663733353138333261
[root@cloudboot inventory]# ansible-vault decrypt loop.yml 
Vault password: 
Decryption successful
[root@cloudboot inventory]# cat loop.yml 
---
- hosts: webservers
  gather_facts: false
  tasks: 
      - name: debug loops
        debug: 
```

ansible-vault用法

```
# ansible-vault -help 
Usage: ansible-vault [create|decrypt|edit|encrypt|encrypt_string|rekey|view] [options] [vaultfile.yml]
```

### Ansbile采集

```
https://github.com/dell/dellemc-openmanage-ansible-modules
https://github.com/HewlettPackard/oneview-ansible
https://github.com/Huawei/Server_Management_Plugin_Ansible
https://github.com/lenovo/ansible-role-lxca-inventory
https://github.com/hellojukay/ansible
```

#### Ansible-Dell

- [dellmc-ansible-modules](https://github.com/dell/dellemc-openmanage-ansible-modules)

#### docker环境

```
➜  ~ docker run -it centos  /bin/bash
[root@f2bea7859ce6 /]# 
[root@f2bea7859ce6 ~]# yum install ansible -y
[root@f2bea7859ce6 ~]# touch /etc/ansible/hosts
[root@f2bea7859ce6 ~]# vi /etc/ansible/hosts 
[hosts]
10.0.10.100
[root@f2bea7859ce6 /]# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
[root@f2bea7859ce6 /]# python get-pip.py 
[root@f2bea7859ce6 ~]# pip install omsdk -i https://pypi.tuna.tsinghua.edu.cn/simple  
[root@f2bea7859ce6 ~]# pip install omdrivers -i https://pypi.tuna.tsinghua.edu.cn/simple
[root@f2bea7859ce6 ~]# yum install git
[root@f2bea7859ce6 ~]# git clone git@github.com:dell/dellemc-openmanage-ansible-modules.git
[root@f2bea7859ce6 ~]# cd dellemc-openmanage-ansible-modules/
[root@f2bea7859ce6 dellemc-openmanage-ansible-modules]# python install.py 
[root@85638d3a995e examples]# ansible-playbook -e "idrac_ip=10.0.10.100 idrac_user=root idrac_pwd=calvin" /examples/dellemc_get_lc_job_status.yml -vvv
```
