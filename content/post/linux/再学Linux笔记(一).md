## 文件及权限

### 权限
- `/etc/password`：密码
- `/etc/shadow` ：个人密码
- `/etc/group`：群组

### 文件

#### rwx的含义

```
[root@e60e84b8f06d /]# ll
total 56
-rw-r--r--   1 root root 12082 Mar  5 17:36 anaconda-post.log
lrwxrwxrwx   1 root root     7 Mar  5 17:34 bin -> usr/bin
```

- rwx分为三组；第一组为当前用户root的操作权限；第二组为当前用户组的操作权限；第三组为其他用户的操作权限
- r=4，w=2，x=1；由此可以算出777，750，755，650，640等的权限含义
- 755=rwxr-xr-x； 640=rw-r-----

#### 修改群组

- chgrp: 修改group
- chmod:  修改权限
  - `chmod u/g/o/a|+/-/=|rwx`: 设置用户/用户组/其他/所有|添加/减去/设定|读写执行 权限
- chown: 修改user属主；
  - ` chown -R root:root`修改用户和用户组为root

#### 切换路径

- `cd `即 `change directory`
- `usr`即`Unix Software Resource`