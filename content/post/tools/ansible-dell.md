### 环境搭建

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



### 参考

```
https://github.com/dell/dellemc-openmanage-ansible-modules
```

