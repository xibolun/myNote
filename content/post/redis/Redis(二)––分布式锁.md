---
date :  "2020-02-27T19:49:47+08:00" 
title : "Redis(二)––分布式锁" 
categories : ["技术文章"] 
tags : ["redis"] 
toc : true
---

### 分布式锁演进

可以使用redis的NX来做处理，需要考虑以下事情

```shell
set key value EX expiration NX
```

#### 锁用完了需要删除

代码需要做锁的释放，否则其他线程的不能获取到锁，导致死锁的情况发生；

#### 若释放锁之前程序已经异常
刚锁上，开始执行业务代码，但是程序需要做捕获异常处理，像Java的try catch，golang的defer

#### 应用宕机？
刚锁上，然后应用发布或者应用直接重启了，此时锁就不会再释放掉；这时可以设置锁的超时时间来解决此问题，当到了一定的时间，锁会自动过期，不会影响其他线程的使用；

#### 多线程之间空锁？

此种情况比较复杂，设置超时时间为10s，A线程拿到锁，执行可能假如是15s；此时B线程可以拿到锁，B线程执行时间为3s，这时B就有可能将A的锁给释放掉了；若多个线程在操作的时候，就可能出现一直锁不住的情况，因为大家拿到锁后会互相删除；可以对每个线程添加一个名称(随机值或者其他的标识位)，删除之间校验一下自己是否是自己的锁；

#### 超时时间如何指定？

如何把握设置长了可能会一直等待，设置短了，直接释放掉了，会导致其他的线程进入；设置长了，程序运行完了还没有释放掉；其他的线程还在等着，性能会受到影响，不过影响不算非常的大；

看一下`Redisson`是如何实现的

[RedissonLock.java](https://github.com/redisson/redisson/blob/master/redisson/src/main/java/org/redisson/RedissonLock.java)

```java
    <T> RFuture<T> tryLockInnerAsync(long leaseTime, TimeUnit unit, long threadId, RedisStrictCommand<T> command) {
        internalLockLeaseTime = unit.toMillis(leaseTime);

        return commandExecutor.evalWriteAsync(getName(), LongCodec.INSTANCE, command,
                  "if (redis.call('exists', KEYS[1]) == 0) then " +
                      "redis.call('hincrby', KEYS[1], ARGV[2], 1); " +
                      "redis.call('pexpire', KEYS[1], ARGV[1]); " +
                      "return nil; " +
                  "end; " +
                  "if (redis.call('hexists', KEYS[1], ARGV[2]) == 1) then " +
                      "redis.call('hincrby', KEYS[1], ARGV[2], 1); " +
                      "redis.call('pexpire', KEYS[1], ARGV[1]); " +
                      "return nil; " +
                  "end; " +
                  "return redis.call('pttl', KEYS[1]);",
                    Collections.<Object>singletonList(getName()), internalLockLeaseTime, getLockName(threadId));
    }
```

使用`luna`脚本对redis底层直接操作；那是如何处理时间的呢？

```java
private void renewExpiration() {
        ExpirationEntry ee = EXPIRATION_RENEWAL_MAP.get(getEntryName());
        if (ee == null) {
            return;
        }
        
        Timeout task = commandExecutor.getConnectionManager().newTimeout(new TimerTask() {
            @Override
            public void run(Timeout timeout) throws Exception {
                ExpirationEntry ent = EXPIRATION_RENEWAL_MAP.get(getEntryName());
                if (ent == null) {
                    return;
                }
                Long threadId = ent.getFirstThreadId();
                if (threadId == null) {
                    return;
                }
                
                RFuture<Boolean> future = renewExpirationAsync(threadId);
                future.onComplete((res, e) -> {
                    if (e != null) {
                        log.error("Can't update lock " + getName() + " expiration", e);
                        return;
                    }
                    
                    if (res) {
                        // reschedule itself
                        renewExpiration();
                    }
                });
            }
        }, internalLockLeaseTime / 3, TimeUnit.MILLISECONDS);
        
        ee.setTimeout(task);
    }
```

对超时时间/3，然后去起一个`Timer`做定期`check`，看看是否此线程持有的锁已经过期；若过期了，线程未执行完，则自动续租时间 ；

所以思路就是，从当前持有锁的线程A当中分出一个线程B，A继续跑自己的业务代码，B代码定时去检查线程的状态和过期时间的平衡；

#### 集群模式节点宕机

此种情形是，线程T拿到了锁，在clusterA上面，若此时clusterA宕机了，则需要分两种情况看待，一种情况A是否进行了replica操作，若操作成功，那就不影响业务，因为其他的线程也不会执行；

若未操作成功，就会有一个线程P进行了锁的操作，所以当前会有两次的业务执行，这样就需要业务方的额外处理；在双11的时候，大家可能会经常遇到，钱扣了两次，然后后续会有客服给你打电话退款就是这种的情况，本人就遇到了一次；

### 基于redis实现一个分布式锁

//TODO