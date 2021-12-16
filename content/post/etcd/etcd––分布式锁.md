### 大纲 

- etcd分布式锁演示：使用etcdctl

- etcd分布式的过期时间

  - etcdctl当中无法设置ttl，因为lock会默认续租：https://github.com/etcd-io/etcd/issues/10096
  - 无法使用lease来关联一个lock，因为etcdctl不支持
  - concurrency当中可以使用lease来对lock进行添加租约；若不使用租约，会默认添加一个60s的租约，当lock释放之后，租约不会立马revoke，而是60s后再revoke

- etcd分布式锁的校验，校验一个key是否被锁定（由于无法获取mutex当中的prx，导致无法校验）

  - 那怎么办呢？锁的时候etcd会以 key/lease_id的形式存储在etcd当中，我们只要根据prefix来读取，是否存在即可

  ```
  # client1上锁
  ➜  ~ etcdctl lock pengganyu --ttl=100
  pengganyu/694d7d563e90b23e
  
  # client2读取
  ➜  ~ etcdctl get --prefix pengganyu/
  pengganyu/694d7d563e90b23e
  ```

