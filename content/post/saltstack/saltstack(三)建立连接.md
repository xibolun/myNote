---
date :  "2019-10-01T10:21:13+08:00" 
title : "SaltStack(三)建立连接" 
categories : ["技术文章"] 
tags : ["saltstack"] 
toc : true
---

### 建立通讯

#### Minion日志

```
[DEBUG   ] Process Manager starting!                                                                                                                [68/256]
[DEBUG   ] Connecting to master. Attempt 1 of 1   
### 获取到master的zmq的地址
[DEBUG   ] Master URI: tcp://192.168.1.253:4506                                                                                                             
### 向zmq发送认证信息
[DEBUG   ] Initializing new AsyncAuth for (u'/etc/salt/pki/minion', u'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6', u'tcp://192.168.1.253:4506')                   
[DEBUG   ] Generated random reconnect delay between '1000ms' and '11000ms' (8413)                                                                           
[DEBUG   ] Setting zmq_reconnect_ivl to '8413ms'                                                                                                            
[DEBUG   ] Setting zmq_reconnect_ivl_max to '11000ms'                                                                                                       
[DEBUG   ] Initializing new AsyncZeroMQReqChannel for (u'/etc/salt/pki/minion', u'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6', u'tcp://192.168.1.253:4506', 'clear
')                                                                                                                                                          
[DEBUG   ] Connecting the Minion to the Master URI (for the return server): tcp://192.168.1.253:4506                                                        
[DEBUG   ] Trying to connect to: tcp://192.168.1.253:4506                       
### 加载公钥
[DEBUG   ] salt.crypt.get_rsa_pub_key: Loading public key                                                                                                   
[DEBUG   ] Decrypting the current master AES key                                                                                                            
[DEBUG   ] salt.crypt.get_rsa_key: Loading private key                                                                                                      
[DEBUG   ] salt.crypt._get_key_with_evict: Loading private key
[DEBUG   ] Loaded minion key: /etc/salt/pki/minion/minion.pem
[DEBUG   ] salt.crypt.get_rsa_pub_key: Loading public key
[DEBUG   ] Closing AsyncZeroMQReqChannel instance
[DEBUG   ] Connecting the Minion to the Master publish port, using the URI: tcp://192.168.1.253:4505
[DEBUG   ] salt.crypt.get_rsa_key: Loading private key
[DEBUG   ] Loaded minion key: /etc/salt/pki/minion/minion.pem
### 使用aes加密算法，向master的zmq发送自己的公钥
[DEBUG   ] Initializing new AsyncZeroMQReqChannel for (u'/etc/salt/pki/minion', u'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6', u'tcp://192.168.1.253:4506', u'aes$
)
[DEBUG   ] Re-using AsyncAuth for (u'/etc/salt/pki/minion', u'AAAAAAAA-0000-0000-BBD1-FA294FBCB7D6', u'tcp://192.168.1.253:4506')
[DEBUG   ] Connecting the Minion to the Master URI (for the return server): tcp://192.168.1.253:4506
[DEBUG   ] Trying to connect to: tcp://192.168.1.253:4506
[DEBUG   ] salt.crypt.get_rsa_key: Loading private key
[DEBUG   ] Loaded minion key: /etc/salt/pki/minion/minion.pem
[DEBUG   ] Closing AsyncZeroMQReqChannel instance
[DEBUG   ] Grains refresh requested. Refreshing grains.
[DEBUG   ] Reading configuration from /etc/salt/minion
[DEBUG   ] Including configuration from '/etc/salt/minion.d/_schedule.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/_schedule.conf
[DEBUG   ] Including configuration from '/etc/salt/minion.d/salt.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/salt.conf
[DEBUG   ] Loading static grains from /etc/salt/grains
[DEBUG   ] Initializing new Schedule
[DEBUG   ] LazyLoaded timezone.get_offset
[DEBUG   ] LazyLoaded cmd.run
[INFO    ] Executing command [u'date', u'+%z'] in directory '/root'
[DEBUG   ] stdout: +0000
[DEBUG   ] output: +0000
[DEBUG   ] LazyLoaded config.merge
[DEBUG   ] SaltEvent PUB socket URI: /var/run/salt/minion/minion_event_fbba871d5e_pub.ipc
[DEBUG   ] SaltEvent PULL socket URI: /var/run/salt/minion/minion_event_fbba871d5e_pull.ipc
[DEBUG   ] Sending event: tag = /salt/minion/minion_schedule_delete_complete; data = {u'_stamp': '2019-10-15T10:31:16.607998', u'complete': True, u'schedule
': {u'__mine_interval': {u'function': u'mine.update', u'run_on_start': True, u'return_job': False, u'enabled': True, u'jid_include': True, u'maxrunning': 2,
 u'minutes': 60}}}
[DEBUG   ] Persisting schedule
[DEBUG   ] Closing IPCMessageClient instance
```

#### Master日志

```
[INFO    ] Creating master process manager        
[INFO    ] Creating master publisher process
[DEBUG   ] Started 'salt.transport.zeromq.<type 'instancemethod'>._publish_daemon' with pid 9360
[INFO    ] Creating master event publisher process
[DEBUG   ] Started 'salt.utils.event.EventPublisher' with pid 9361
[INFO    ] Starting the Salt Publisher on tcp://0.0.0.0:4505
[INFO    ] Starting the Salt Puller on ipc:///var/run/salt/master/publish_pull.ipc
[DEBUG   ] Publish daemon getting data from puller ipc:///var/run/salt/master/publish_pull.ipc
[INFO    ] Creating master maintenance process
[DEBUG   ] Started 'salt.master.Maintenance' with pid 9364
[INFO    ] Creating master request server process
[DEBUG   ] Started 'ReqServer' with pid 9366
[DEBUG   ] Initializing new Schedule
[DEBUG   ] Started 'salt.transport.zeromq.<type 'instancemethod'>.zmq_device' with pid 9367
[DEBUG   ] Started 'MWorker-0' with pid 9369
[INFO    ] Setting up the master communication server
[DEBUG   ] Started 'MWorker-1' with pid 9370
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Started 'MWorker-2' with pid 9371
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Started 'MWorker-3' with pid 9372
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Started 'MWorker-4' with pid 9373
[DEBUG   ] Process Manager starting!
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Started 'salt.master.FileserverUpdate' with pid 9374
[DEBUG   ] Process Manager starting!
[DEBUG   ] Performing fileserver updates for items with an update interval of 60
[DEBUG   ] Updating roots fileserver cache
[DEBUG   ] Completed fileserver updates for items with an update interval of 60, waiting 60 seconds
[DEBUG   ] Could not LazyLoad timezone.get_offset: 'timezone.get_offset' is not available.
[DEBUG   ] Could not LazyLoad config.merge: 'config.merge' is not available.
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] This salt-master instance has accepted 1 minion keys.
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Missing configuration file: /Users/admin/.saltrc
[DEBUG   ] Missing configuration file: /Users/admin/.saltrc
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Missing configuration file: /Users/admin/.saltrc
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] Missing configuration file: /Users/admin/.saltrc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Missing configuration file: /Users/admin/.saltrc
[DEBUG   ] MasterEvent PUB socket URI: /var/run/salt/master/master_event_pub.ipc
[DEBUG   ] MasterEvent PULL socket URI: /var/run/salt/master/master_event_pull.ipc
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Including configuration from '/etc/salt/minion.d/_schedule.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/_schedule.conf
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Grains refresh requested. Refreshing grains.
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Including configuration from '/etc/salt/minion.d/_schedule.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/_schedule.conf
[DEBUG   ] Including configuration from '/etc/salt/minion.d/_schedule.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/_schedule.conf
[DEBUG   ] Including configuration from '/etc/salt/minion.d/_schedule.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/_schedule.conf
[DEBUG   ] Including configuration from '/etc/salt/minion.d/_schedule.conf'
[DEBUG   ] Reading configuration from /etc/salt/minion.d/_schedule.conf
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Grains refresh requested. Refreshing grains.
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Using cached minion ID from /etc/salt/minion_id: 1.0.0.127.in-addr.arpa
[DEBUG   ] Grains refresh requested. Refreshing grains.
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Grains refresh requested. Refreshing grains.
[DEBUG   ] Reading configuration from /etc/salt/master
[DEBUG   ] Grains refresh requested. Refreshing grains.
[DEBUG   ] Reading configuration from /etc/salt/master
```



- [salt-communication](https://docs.saltstack.com/en/getstarted/system/communication.html)