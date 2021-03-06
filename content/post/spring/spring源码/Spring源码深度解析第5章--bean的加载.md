---

date :  "2017-08-21T23:36:24+08:00" 
title : "Spring源码深度解析第5章--bean的加载" 
categories : ["技术文章"] 
tags : ["spring"] 
toc : true
---


5.1 FactoryBean的使用
---------------------

``` {.java}
  /*** AbstractBeanFactory.doGetBean方法加载bean **/

    protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
            @Nullable final Object[] args, boolean typeCheckOnly) throws BeansException {}
```

### 转换beanName

-   spring的FactoryBean是以&开头的，若一个beanName是以&开头的，说明是FactoryBean，需要截取&后面的内容
-   判断此name是否为aliasName，若在aliasMap当中可以找得到，那么需要给出alias的真正名称

``` {.java}
        final String beanName = transformedBeanName(name);

protected String transformedBeanName(String name) {
        return canonicalName(BeanFactoryUtils.transformedBeanName(name));
    }
```

``` {.java}
public static String transformedBeanName(String name) {
        Assert.notNull(name, "'name' must not be null");
        String beanName = name;
        while (beanName.startsWith(BeanFactory.FACTORY_BEAN_PREFIX)) {
            beanName = beanName.substring(BeanFactory.FACTORY_BEAN_PREFIX.length());
        }
        return beanName;
    }

    public String canonicalName(String name) {
        String canonicalName = name;
        // Handle aliasing...
        String resolvedName;
        do {
            resolvedName = this.aliasMap.get(canonicalName);
            if (resolvedName != null) {
                canonicalName = resolvedName;
            }
        }
        while (resolvedName != null);
        return canonicalName;
    }
```

5.2 缓存中获取单例bean
----------------------

### 根据beanName在单例当中查找Bean,单例可以解决循环依赖

``` {.java}
        Object sharedInstance = getSingleton(beanName);
```

``` {.java}
  /** Cache of early singleton objects: bean name --> bean instance */
    private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);

    /** Cache of singleton factories: bean name --> ObjectFactory */
    private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);

    /** Cache of singleton objects: bean name --> bean instance */
    private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

    protected Object getSingleton(String beanName, boolean allowEarlyReference) {
        Object singletonObject = this.singletonObjects.get(beanName);
        if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
            synchronized (this.singletonObjects) {
                singletonObject = this.earlySingletonObjects.get(beanName);
                if (singletonObject == null && allowEarlyReference) {
                    ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                    if (singletonFactory != null) {
                        singletonObject = singletonFactory.getObject();
                        this.earlySingletonObjects.put(beanName, singletonObject);
                        this.singletonFactories.remove(beanName);
                    }
                }
            }
        }
        return (singletonObject != NULL_OBJECT ? singletonObject : null);
    }
```

-   首先看缓存的singletonObjects当中是否存在bean，若存在直接就返回
-   若不存在，则去查找缓存的earlySingletonObjects当中是否存在
-   若不存在，则查找singlegonFactories当中是否存在
-   若存在，则将bean缓存起来
-   singletonObjects里面在存放着BeanName和BeanInstance之前的关系
-   singletonFactories里面存放着BeanName和FactoryBean之间的关系

5.5 准备开始创建Bean
--------------------

### 若在单例的缓存当中不存在，则判断bean是否在创建当中

``` {.java}
      // Fail if we're already creating this bean instance:
            // We're assumably within a circular reference.
            if (isPrototypeCurrentlyInCreation(beanName)) {
                throw new BeanCurrentlyInCreationException(beanName);
            }

       /** 使用了多线程共享 **/
    private final ThreadLocal<Object> prototypesCurrentlyInCreation =
            new NamedThreadLocal<>("Prototype beans currently in creation");

    protected boolean isPrototypeCurrentlyInCreation(String beanName) {
        Object curVal = this.prototypesCurrentlyInCreation.get();
        return (curVal != null &&
                (curVal.equals(beanName) || (curVal instanceof Set && ((Set<?>) curVal).contains(beanName))));
    }
```

### 若不在创建当中，去parentFactory当中找

``` {.java}

            // Check if bean definition exists in this factory.
            BeanFactory parentBeanFactory = getParentBeanFactory();
            if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {
                // Not found -> check parent.
                String nameToLookup = originalBeanName(name);
                if (parentBeanFactory instanceof AbstractBeanFactory) {
                    return ((AbstractBeanFactory) parentBeanFactory).doGetBean(
                            nameToLookup, requiredType, args, typeCheckOnly);
                }
                else if (args != null) {
                    // Delegation to parent with explicit args.
                    return (T) parentBeanFactory.getBean(nameToLookup, args);
                }
                else {
                    // No args -> delegate to standard getBean method.
                    return parentBeanFactory.getBean(nameToLookup, requiredType);
                }
            }
```

5.6 循环依赖-spring如何解决循环依赖
-----------------------------------

``` {.java}
      // Fail if we're already creating this bean instance:
            // We're assumably within a circular reference.
            if (isPrototypeCurrentlyInCreation(beanName)) {
                throw new BeanCurrentlyInCreationException(beanName);
            }
```

-   将需要创建的beanName放入到prototypesCurrentlyInCreation当中，若已经存在则抛出异常
-   若循环依赖，抛出异常BeanCurrentlyInCreationException

5.7 创建bean
------------

``` {.java}
    protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
            throws BeanCreationException {}

    /** 若是单例的，清除缓存 ，并重新实例化**/
        BeanWrapper instanceWrapper = null;
        if (mbd.isSingleton()) {
            instanceWrapper = this.factoryBeanInstanceCache.remove(beanName);
        }
        if (instanceWrapper == null) {
            instanceWrapper = createBeanInstance(beanName, mbd, args);
        }


        // Initialize the bean instance.
        Object exposedObject = bean;
        try {
            populateBean(beanName, mbd, instanceWrapper);
            if (exposedObject != null) {
                exposedObject = initializeBean(beanName, exposedObject, mbd);
            }
        }
```

-   整个Spring实例化bean就是放到createBeanInstance或者initializeBean当中

### 5.7.5 注册bean--AbstractBeanFactory.registerDisposableBeanIfNecessary

``` {.java}
    protected void registerDisposableBeanIfNecessary(String beanName, Object bean, RootBeanDefinition mbd) {
        AccessControlContext acc = (System.getSecurityManager() != null ? getAccessControlContext() : null);
        if (!mbd.isPrototype() && requiresDestruction(bean, mbd)) {
            if (mbd.isSingleton()) {
                // Register a DisposableBean implementation that performs all destruction
                // work for the given bean: DestructionAwareBeanPostProcessors,
                // DisposableBean interface, custom destroy method.
                registerDisposableBean(beanName,
                        new DisposableBeanAdapter(bean, beanName, mbd, getBeanPostProcessors(), acc));
            }
            else {
                // A bean with a custom scope...
                Scope scope = this.scopes.get(mbd.getScope());
                if (scope == null) {
                    throw new IllegalStateException("No Scope registered for scope name '" + mbd.getScope() + "'");
                }
                scope.registerDestructionCallback(beanName,
                        new DisposableBeanAdapter(bean, beanName, mbd, getBeanPostProcessors(), acc));
            }
        }
    }
```

-   所有的bean都会放到disposable当中，disposable是一个LinkedHashMap,beanName作为key，bean作为value
-   若为单例，直接放入到disposabled当中，若为自定义范围，则调用自定义的接口进行处理

