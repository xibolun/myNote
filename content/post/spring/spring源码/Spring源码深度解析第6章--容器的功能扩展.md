---

date :  "2017-08-29T23:36:24+08:00" 
title : "Spring源码深度解析第6章--容器的功能扩展" 
categories : ["技术文章"] 
tags : ["spring"] 
toc : true
---


概述
----

spring不仅仅提供了xmlBeanFactory，还提供了ApplictionContext用于扩展BeanFactory当中的功能;ApplicationContext拥有BeanFactory所有的功能;

``` {.java}
        ApplicationContext factory = new ClassPathXmlApplicationContext("beanFactory.xml");
```

下面对此代码进行分析，ClassPathXmlApplicationContext如何处理加载bean的

6.1 设置配置路径
----------------

``` {.java}
    public ClassPathXmlApplicationContext(String configLocation) throws BeansException {
        this(new String[] {configLocation}, true, null);
    }
```

``` {.java}
public ClassPathXmlApplicationContext(String[] configLocations, boolean refresh, ApplicationContext parent)
            throws BeansException {

        super(parent);
        setConfigLocations(configLocations);
        if (refresh) {
            refresh();
        }
    }
```

``` {.java}
public void setConfigLocations(String... locations) {
        if (locations != null) {
            Assert.noNullElements(locations, "Config locations must not be null");
            this.configLocations = new String[locations.length];
            for (int i = 0; i < locations.length; i++) {
                this.configLocations[i] = resolvePath(locations[i]).trim();
            }
        }
        else {
            this.configLocations = null;
        }
    }
```

-   将路径配置转换为String\[\]进行处理
-   解析配置信息并将其放入到AbstractRefreshableConfigApplicationContext.configLocations当中，其中configLocations是一个String\[\]；
-   refresh()刷新配置信息

6.2 扩展功能
------------

``` {.java}
public void refresh() throws BeansException, IllegalStateException {
        synchronized (this.startupShutdownMonitor) {
            // Prepare this context for refreshing.
            prepareRefresh();

            // Tell the subclass to refresh the internal bean factory.
            ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

            // Prepare the bean factory for use in this context.
            prepareBeanFactory(beanFactory);

            try {
                // Allows post-processing of the bean factory in context subclasses.
                postProcessBeanFactory(beanFactory);

                // Invoke factory processors registered as beans in the context.
                invokeBeanFactoryPostProcessors(beanFactory);

                // Register bean processors that intercept bean creation.
                registerBeanPostProcessors(beanFactory);

                // Initialize message source for this context.
                initMessageSource();

                // Initialize event multicaster for this context.
                initApplicationEventMulticaster();

                // Initialize other special beans in specific context subclasses.
                onRefresh();

                // Check for listener beans and register them.
                registerListeners();

                // Instantiate all remaining (non-lazy-init) singletons.
                finishBeanFactoryInitialization(beanFactory);

                // Last step: publish corresponding event.
                finishRefresh();
            }

            catch (BeansException ex) {
                if (logger.isWarnEnabled()) {
                    logger.warn("Exception encountered during context initialization - " +
                            "cancelling refresh attempt: " + ex);
                }

                // Destroy already created singletons to avoid dangling resources.
                destroyBeans();

                // Reset 'active' flag.
                cancelRefresh(ex);

                // Propagate exception to caller.
                throw ex;
            }

            finally {
                // Reset common introspection caches in Spring's core, since we
                // might not ever need metadata for singleton beans anymore...
                resetCommonCaches();
            }
        }
    }
```

6.3 环境准备
------------

``` {.java}
protected void prepareRefresh() {
        this.startupDate = System.currentTimeMillis();
        this.closed.set(false);
        this.active.set(true);

        if (logger.isInfoEnabled()) {
            logger.info("Refreshing " + this);
        }

        // Initialize any placeholder property sources in the context environment
        initPropertySources();

        // Validate that all properties marked as required are resolvable
        // see ConfigurablePropertyResolver#setRequiredProperties
        getEnvironment().validateRequiredProperties();

        // Allow for the collection of early ApplicationEvents,
        // to be published once the multicaster is available...
        this.earlyApplicationEvents = new LinkedHashSet<>();
    }
```

若一个类继承了ClassPathXmlContext方法，并覆写了initPropertySource()方法的时候，spring在环境准备的时候就会将此类对应的初始化准备工作添加；我们可以通过这一特性去添加一些扩展的校验及环境的检测

6.4 加载BeanFactory
-------------------

加载beanFactory，主要都集中在refreshBeanFactory当中

``` {.java}
@Override
    protected final void refreshBeanFactory() throws BeansException {
        if (hasBeanFactory()) {
            destroyBeans();
            closeBeanFactory();
        }
        try {
            DefaultListableBeanFactory beanFactory = createBeanFactory();
            beanFactory.setSerializationId(getId());
      //定制beanFactory
            customizeBeanFactory(beanFactory);
      //加载bean定义
            loadBeanDefinitions(beanFactory);
            synchronized (this.beanFactoryMonitor) {
                this.beanFactory = beanFactory;
            }
        }
        catch (IOException ex) {
            throw new ApplicationContextException("I/O error parsing bean definition source for " + getDisplayName(), ex);
        }
    }
```

### 6.4.1 定制beanFactory

``` {.java}
protected void customizeBeanFactory(DefaultListableBeanFactory beanFactory) {
        if (this.allowBeanDefinitionOverriding != null) {
            beanFactory.setAllowBeanDefinitionOverriding(this.allowBeanDefinitionOverriding);
        }
        if (this.allowCircularReferences != null) {
            beanFactory.setAllowCircularReferences(this.allowCircularReferences);
        }
    }
```

-   allowBeanDefinitionOverriding:
    允许重复定义，即@Qualifer和@Autowired的使用
-   allowCircularReference: 设置是否允许依赖
-   用户可以在子类当中手工设置这两个属性

### 6.4.2 加载bean定义

``` {.java}
    protected void loadBeanDefinitions(DefaultListableBeanFactory beanFactory) throws BeansException, IOException {
        // Create a new XmlBeanDefinitionReader for the given BeanFactory.
        XmlBeanDefinitionReader beanDefinitionReader = new XmlBeanDefinitionReader(beanFactory);

        // Configure the bean definition reader with this context's
        // resource loading environment.
        beanDefinitionReader.setEnvironment(this.getEnvironment());
        beanDefinitionReader.setResourceLoader(this);
        beanDefinitionReader.setEntityResolver(new ResourceEntityResolver(this));

        // Allow a subclass to provide custom initialization of the reader,
        // then proceed with actually loading the bean definitions.
        initBeanDefinitionReader(beanDefinitionReader);
        loadBeanDefinitions(beanDefinitionReader);
    }

```

-   首先获取xmlBeanDefinitionReader，用于读取xml配置
-   设置xmlreader的一些属性
-   开始加载xml定义，xmlBeanDefinitionReader读取的xml配置信息都会放入到beanFactory当中

6.5 功能扩展
------------

在refresh()方法里面，在环境准备及加载beanFactory之后，开始准备beanFactory的一些功能扩展

``` {.java}
protected void prepareBeanFactory(ConfigurableListableBeanFactory beanFactory) {
        // Tell the internal bean factory to use the context's class loader etc.
        beanFactory.setBeanClassLoader(getClassLoader());
        beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
        beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));

        // Configure the bean factory with context callbacks.
        beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
        beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
        beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
        beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
        beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);

        // BeanFactory interface not registered as resolvable type in a plain factory.
        // MessageSource registered (and found for autowiring) as a bean.
        beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
        beanFactory.registerResolvableDependency(ResourceLoader.class, this);
        beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
        beanFactory.registerResolvableDependency(ApplicationContext.class, this);

        // Register early post-processor for detecting inner beans as ApplicationListeners.
        beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(this));

        // Detect a LoadTimeWeaver and prepare for weaving, if found.
        if (beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
            beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
            // Set a temporary ClassLoader for type matching.
            beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
        }

        // Register default environment beans.
        if (!beanFactory.containsLocalBean(ENVIRONMENT_BEAN_NAME)) {
            beanFactory.registerSingleton(ENVIRONMENT_BEAN_NAME, getEnvironment());
        }
        if (!beanFactory.containsLocalBean(SYSTEM_PROPERTIES_BEAN_NAME)) {
            beanFactory.registerSingleton(SYSTEM_PROPERTIES_BEAN_NAME, getEnvironment().getSystemProperties());
        }
        if (!beanFactory.containsLocalBean(SYSTEM_ENVIRONMENT_BEAN_NAME)) {
            beanFactory.registerSingleton(SYSTEM_ENVIRONMENT_BEAN_NAME, getEnvironment().getSystemEnvironment());
        }
    }
```

### 6.5.1 SPEL语言支持

``` {.java}
        beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
```

-   什么叫SPEL: Spring Expression Language，使用\#{xxx}来描述

### 6.5.2 增加属性注册编辑器

``` {.java}
        beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));
```

-   这个属性注册编辑器是什么东西？当我们在定义spring配置文件的时候，有一些属性需要进行转换，比如说字符串转日期，Spring是没有办法处理，需要我们自定义一个编辑器来解析日期类型的字符串信息

``` {.xml}
<bean id="configBean"   class="org.springframework.beans.factory.config.CustomEditorConfigurer">  
   <property name="customEditors">  
    <map>  
       <entry key="User">  <!-- 属性类型 -->    
             <bean class="TransformUser"/>  <!--对应Address的编辑器 -->    
       </entry>  
    </map>  
   </property>  
</bean>  
```

-   比如说上面的例子里面，将User转换为TransformUser；其中TransformUser是继承了PropertyEditorSupport

### 6.5.3 添加ApplicationContextAwareProcessor处理器

-   ApplicationContextAwareProcessor是干什么用的？它是BeanPostProcessor的一种，和BeanPostProcessor一样，同样有postProcessBeforeInitialization和postProcessAfterInitialization方法，但是ApplicationContextAwareProcessor的postProcessBeforeInitialization方法增强了对Aware资源的调用

``` {.java}
@Override
    public Object postProcessBeforeInitialization(final Object bean, String beanName) throws BeansException {
        AccessControlContext acc = null;

        if (System.getSecurityManager() != null &&
                (bean instanceof EnvironmentAware || bean instanceof EmbeddedValueResolverAware ||
                        bean instanceof ResourceLoaderAware || bean instanceof ApplicationEventPublisherAware ||
                        bean instanceof MessageSourceAware || bean instanceof ApplicationContextAware)) {
            acc = this.applicationContext.getBeanFactory().getAccessControlContext();
        }

        if (acc != null) {
            AccessController.doPrivileged((PrivilegedAction<Object>) () -> {
                invokeAwareInterfaces(bean);
                return null;
            }, acc);
        }
        else {
            invokeAwareInterfaces(bean);
        }

        return bean;
    }

    private void invokeAwareInterfaces(Object bean) {
        if (bean instanceof Aware) {
            if (bean instanceof EnvironmentAware) {
                ((EnvironmentAware) bean).setEnvironment(this.applicationContext.getEnvironment());
            }
            if (bean instanceof EmbeddedValueResolverAware) {
                ((EmbeddedValueResolverAware) bean).setEmbeddedValueResolver(this.embeddedValueResolver);
            }
            if (bean instanceof ResourceLoaderAware) {
                ((ResourceLoaderAware) bean).setResourceLoader(this.applicationContext);
            }
            if (bean instanceof ApplicationEventPublisherAware) {
                ((ApplicationEventPublisherAware) bean).setApplicationEventPublisher(this.applicationContext);
            }
            if (bean instanceof MessageSourceAware) {
                ((MessageSourceAware) bean).setMessageSource(this.applicationContext);
            }
            if (bean instanceof ApplicationContextAware) {
                ((ApplicationContextAware) bean).setApplicationContext(this.applicationContext);
            }
        }
    }
```

### 6.5.4 设置忽略依赖

-   为什么要设置忽略？当Spring将ApplicationContextAwareProcessor注册后，
    就不需要注入上面ApplicationContextAwareProcessor已经添加的Aware类了；见ApplicationContextAwareProcessor.invokeAwareInterfaces方法

### 6.5.5 注册依赖

``` {.java}
        beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
        beanFactory.registerResolvableDependency(ResourceLoader.class, this);
        beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
        beanFactory.registerResolvableDependency(ApplicationContext.class, this);
```

6.6 BeanFactory后的处理
-----------------------

### 6.6.1 BeanFactoryPostProcessor的作用

-   对BeanDefinition进行修改，可以改变其中的元数据信息
-   根据beanProperty当中定义的username替换xml当中的\${username}

Spring激活beanFactoryPostProcessor

``` {.java}
class PostProcessorRegistrationDelegate {

    public static void invokeBeanFactoryPostProcessors(ConfigurableListableBeanFactory beanFactory, List<BeanFactoryPostProcessor> beanFactoryPostProcessors)

}
```

### 6.6.2 注册BeanPostProcessor-- registerBeanPostProcessors

### 6.6.3 初始化消息资源-- initMessageSource

-   什么是MessageSource；国际化的处理，不同语言的提示信息是不一样的，所以通过配置文件的方式，将异常码或者异常提示等信息国际化

### 6.6.4 初始化ApplicationEventMulticaster

-   使用了设计模式当中的观察者模式
-   初始化事件事件广播器,自定义广播器初始化和SimpleApplicationEventMulticaster广播器初始化

### 6.6.5 注册监听器 registerListeners

6.7 初始化非延迟加载单例
------------------------

### 6.7.1 ConversionService设置

-   ConversionService是做什么的？是做类型转换的，比如说将String类型的true、false转换为Boolean类型

``` {.java}
    // Initialize conversion service for this context.
        if (beanFactory.containsBean(CONVERSION_SERVICE_BEAN_NAME) &&
                beanFactory.isTypeMatch(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class)) {
            beanFactory.setConversionService(
                    beanFactory.getBean(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class));
        }
```

### 6.7.2 冻结配置

-   为什么要冻结配置？需要说明这些已经加载的配置不能再被修改了

``` {.java}

        // Allow for caching all bean definition metadata, not expecting further changes.
        beanFactory.freezeConfiguration();

```

### 6.7.3 非延迟加载

-   为什么说是非延迟加载？因为Spring会将单例bean提前初始化，这样做的好处就是说可以提前发现问题

``` {.java}
        beanFactory.preInstantiateSingletons();
```

6.8 finishRefresh()
-------------------

-   Lifecycle可以控制bean的start和stop一些操作

``` {.java}

/**
     * Finish the refresh of this context, invoking the LifecycleProcessor's
     * onRefresh() method and publishing the
     * {@link org.springframework.context.event.ContextRefreshedEvent}.
     */
    protected void finishRefresh() {
        // Clear context-level resource caches (such as ASM metadata from scanning).
        clearResourceCaches();

        // Initialize lifecycle processor for this context.
        initLifecycleProcessor();

        // Propagate refresh to lifecycle processor first.
        getLifecycleProcessor().onRefresh();

        // Publish the final event.
        publishEvent(new ContextRefreshedEvent(this));

        // Participate in LiveBeansView MBean, if active.
        LiveBeansView.registerApplicationContext(this);
    }

```
