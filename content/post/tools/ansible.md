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

### 原理

### 名词

- adhoc：可以快速执行的一些命令，比如说查看rpm包、服务信息，文件权限等`-m`参数执行
- playbooks：ansible的配置、发布、编排语言，将你需要的配置改成目标即可
- invertory：主机信息配置文件，ansible通过读取此配置文件来获取到需要执行的目标机器，主机列表支持group和pattern
- Cobbler：ansible的一个插件，RHEL发版，管理DNS和DHCP网络的工具

### 各模块说明

#### 配置文件

* `ANSIBLE_CONFIG` (一个环境变量)
* `ansible.cfg` (位于当前目录中)
* `.ansible.cfg` (位于根目录中)
* `/etc/ansible/ansible.cfg`
* 配置项列表说明：[ansbile.cfg](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)



### 案例

- nginx启停

  ```
  ansible hosts -m service -a "name=nginx state=started" -u root
  ansible hosts -m service -a "name=nginx state=stopped" -u root
  ```

  

#### ansbile采集

```
https://github.com/dell/dellemc-openmanage-ansible-modules
https://github.com/HewlettPackard/oneview-ansible
https://github.com/Huawei/Server_Management_Plugin_Ansible
https://github.com/lenovo/ansible-role-lxca-inventory
https://github.com/hellojukay/ansible
```

