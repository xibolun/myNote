---

date :  "2017-09-04T23:36:24+08:00" 
title : "Spring源码深度解析第7章--AOP" 
categories : ["技术文章"] 
tags : ["spring"] 
toc : true
---

前言
----

### 什么是AOP？为什么要玩AOP

-   AOP是Aspect Oriented Programming，意即面向切面编程
-   面向对向编程是竖向的方式；无法对多个对象进行同时的操作，只能在每个对象当中引入公共的代码，这样就导致代码的重复；程序不易维护；所以就有了AOP
-   比如说你怎么在所有的controller的方法里面输入一行hello
    world？如果不使用切面，你可能写个工具类，每个controller方法都需要添加一行代码、而切面就不需要这样操作

7.1 学习使用AOP
---------------

### 一个demo

-   在Spring
    boot当中简化了xml配置，只需要在切面的方法上面添加@Configuration注解即可
-   以下demo为切所有的controller层，其中execution及Pointcut、Around的用法后面会再深入学习

``` {.java}
@Aspect
@Configuration
public class AspectController {
    @Pointcut("execution(* com.idcos.automate.web.controller..*.*(..))")
    public void pointcut() {
        System.out.println("start aspect ......");
    }

    @Before("pointcut()")
    public void beforeCut() {
        System.out.println("beforeCut");
    }


    @After("pointcut()")
    public void afterCut() {
        System.out.println("afterCut");
    }

    @AfterThrowing("pointcut()")
    public void afterThrowing() {
        System.out.println("afterThrowing");
    }

    @AfterReturning("pointcut()")
    public void afterReturning() {
        System.out.println("afterReturning");
    }

    @Around("pointcut()")
    public Object doAround(ProceedingJoinPoint pjp) throws Throwable {
        System.out.println("start aspect");
        RequestAttributes ra = RequestContextHolder.getRequestAttributes();
        ServletRequestAttributes sra = (ServletRequestAttributes) ra;
        HttpServletRequest request = sra.getRequest();

        String url = request.getRequestURL().toString();
        String method = request.getMethod();
        String uri = request.getRequestURI();
        String queryString = request.getQueryString();

        // result的值就是被拦截方法的返回值
        Object result = pjp.proceed();

        System.out.println(JSON.toJSONString(result));
        return result;
    }
}

```

### 核心概念

1.  横切关注点，切哪些方法，切完之后需要做什么事情
2.  aspect： 横切，标记此类是一个切面类，对横切的抽象
3.  joinpoint：连接点，连接点可以是方法，属性或者构造方法
4.  Pointcut： 切入点，对连接点进行拦截定义
5.  advice：
    通知，拦截到连接点后进行通知，通知分为前置(Before)、环绕(Around),后置(After)、异常(AfterThrowing),最终(AfterReturning)，也即为执行顺序
6.  target： 目标对象，代理的目标对象
7.  weave：织入
8.  introduction：引入

7.2 动态AOP自定义标签
---------------------

### 7.2.1 Spring如何解析Aspect相关的标签？

``` {.java}
public class AopNamespaceHandler extends NamespaceHandlerSupport {

    /**
     * Register the {@link BeanDefinitionParser BeanDefinitionParsers} for the
     * '{@code config}', '{@code spring-configured}', '{@code aspectj-autoproxy}'
     * and '{@code scoped-proxy}' tags.
     */
    @Override
    public void init() {
        // In 2.0 XSD as well as in 2.1 XSD.
        registerBeanDefinitionParser("config", new ConfigBeanDefinitionParser());
        registerBeanDefinitionParser("aspectj-autoproxy", new AspectJAutoProxyBeanDefinitionParser());
        registerBeanDefinitionDecorator("scoped-proxy", new ScopedProxyBeanDefinitionDecorator());

        // Only in 2.0 XSD: moved to context namespace as of 2.1
        registerBeanDefinitionParser("spring-configured", new SpringConfiguredBeanDefinitionParser());
    }

}
```

可以看出当遇到aspectj相关的xml标签的时候，都会使用AspectJAutoProxyBeanDefinitionParser解析器进行解析

7.3 创建AOP代理
---------------

-   本部分是AOP的核心
-   怎么提取Advisor
-   怎么获取Aspect注解
-   怎么加载增加器

``` {.java}
// 开始处理AOP信息
// AbstractAutoProxyCreator.postProcessAfterInitialization
    public Object postProcessAfterInitialization(@Nullable Object bean, String beanName) throws BeansException {
        if (bean != null) {
            Object cacheKey = getCacheKey(bean.getClass(), beanName);
            if (!this.earlyProxyReferences.contains(cacheKey)) {
                return wrapIfNecessary(bean, beanName, cacheKey);
            }
        }
        return bean;
    }

// wrapIfNecessary里面包括着对于bean的处理逻辑

protected Object wrapIfNecessary(Object bean, String beanName, Object cacheKey) {
        // 若已经处理，则无需再处理
        if (StringUtils.hasLength(beanName) && this.targetSourcedBeans.contains(beanName)) {
            return bean;
        }
        // 若不需要增强，则直接返回
        if (Boolean.FALSE.equals(this.advisedBeans.get(cacheKey))) {
            return bean;
        }
        // 是否是基础设施类； 是否跳过代理
        if (isInfrastructureClass(bean.getClass()) || shouldSkip(bean.getClass(), beanName)) {
            this.advisedBeans.put(cacheKey, Boolean.FALSE);
            return bean;
        }

        // Create proxy if we have advice.
        Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);
        if (specificInterceptors != DO_NOT_PROXY) {
            this.advisedBeans.put(cacheKey, Boolean.TRUE);
            Object proxy = createProxy(
                    bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
            this.proxyTypes.put(cacheKey, proxy.getClass());
            return proxy;
        }

        this.advisedBeans.put(cacheKey, Boolean.FALSE);
        return bean;
    }
```

### 7.3.1 获取增强器

``` {.java}
    @Override
    @Nullable
    protected Object[] getAdvicesAndAdvisorsForBean(Class<?> beanClass, String beanName, @Nullable TargetSource targetSource) {
        List<Advisor> advisors = findEligibleAdvisors(beanClass, beanName);
        if (advisors.isEmpty()) {
            return DO_NOT_PROXY;
        }
        return advisors.toArray();
    }


protected List<Advisor> findEligibleAdvisors(Class<?> beanClass, String beanName) {
// 其中findCandidateAdvisors就是获取增强器
        List<Advisor> candidateAdvisors = findCandidateAdvisors();
        List<Advisor> eligibleAdvisors = findAdvisorsThatCanApply(candidateAdvisors, beanClass, beanName);
        extendAdvisors(eligibleAdvisors);
        if (!eligibleAdvisors.isEmpty()) {
            eligibleAdvisors = sortAdvisors(eligibleAdvisors);
        }
        return eligibleAdvisors;
    }


    @Override
    protected List<Advisor> findCandidateAdvisors() {
        // Add all the Spring advisors found according to superclass rules.
        List<Advisor> advisors = super.findCandidateAdvisors();
        // Build Advisors for all AspectJ aspects in the bean factory.
        if (this.aspectJAdvisorsBuilder != null) {
            // 加载所有有关Aspect注解的相关增加数据信息
            // 遍历beanFactory当中的bean，寻找是否存在Aspect相关注解，并将解析的结果放入缓存当中
            advisors.addAll(this.aspectJAdvisorsBuilder.buildAspectJAdvisors());
        }
        return advisors;
    }

// 其中getAdvisors是处理Advisor最核心的逻辑
List<Advisor> classAdvisors = this.advisorFactory.getAdvisors(factory);



```

#### 寻找pointCut里面的expression

``` {.java}

// ReflectiveAspectJAdvisorFactory.getPointcut()
    @Nullable
    private AspectJExpressionPointcut getPointcut(Method candidateAdviceMethod, Class<?> candidateAspectClass) {
        AspectJAnnotation<?> aspectJAnnotation =
                AbstractAspectJAdvisorFactory.findAspectJAnnotationOnMethod(candidateAdviceMethod);
        if (aspectJAnnotation == null) {
            return null;
        }

        AspectJExpressionPointcut ajexp =
                new AspectJExpressionPointcut(candidateAspectClass, new String[0], new Class<?>[0]);
        ajexp.setExpression(aspectJAnnotation.getPointcutExpression());
        if (this.beanFactory != null) {
            ajexp.setBeanFactory(this.beanFactory);
        }
        return ajexp;
    }
```

#### 切点信息增强

``` {.java}
public InstantiationModelAwarePointcutAdvisorImpl(AspectJExpressionPointcut declaredPointcut,
            Method aspectJAdviceMethod, AspectJAdvisorFactory aspectJAdvisorFactory,
            MetadataAwareAspectInstanceFactory aspectInstanceFactory, int declarationOrder, String aspectName) {

        this.declaredPointcut = declaredPointcut;
        this.declaringClass = aspectJAdviceMethod.getDeclaringClass();
        this.methodName = aspectJAdviceMethod.getName();
        this.parameterTypes = aspectJAdviceMethod.getParameterTypes();
        this.aspectJAdviceMethod = aspectJAdviceMethod;
        this.aspectJAdvisorFactory = aspectJAdvisorFactory;
        this.aspectInstanceFactory = aspectInstanceFactory;
        this.declarationOrder = declarationOrder;
        this.aspectName = aspectName;

        if (aspectInstanceFactory.getAspectMetadata().isLazilyInstantiated()) {
            // Static part of the pointcut is a lazy type.
            Pointcut preInstantiationPointcut = Pointcuts.union(
                    aspectInstanceFactory.getAspectMetadata().getPerClausePointcut(), this.declaredPointcut);

            // Make it dynamic: must mutate from pre-instantiation to post-instantiation state.
            // If it's not a dynamic pointcut, it may be optimized out
            // by the Spring AOP infrastructure after the first evaluation.
            this.pointcut = new PerTargetInstantiationModelPointcut(
                    this.declaredPointcut, preInstantiationPointcut, aspectInstanceFactory);
            this.lazy = true;
        }
        else {
            // A singleton aspect.
            this.pointcut = this.declaredPointcut;
            this.lazy = false;
            this.instantiatedAdvice = instantiateAdvice(this.declaredPointcut);
        }
    }
```

#### 处理before、after等注解信息

``` {.java}
@Override
    public Advice getAdvice(Method candidateAdviceMethod, AspectJExpressionPointcut expressionPointcut,
            MetadataAwareAspectInstanceFactory aspectInstanceFactory, int declarationOrder, String aspectName) {

        Class<?> candidateAspectClass = aspectInstanceFactory.getAspectMetadata().getAspectClass();
        validate(candidateAspectClass);

        AspectJAnnotation<?> aspectJAnnotation =
                AbstractAspectJAdvisorFactory.findAspectJAnnotationOnMethod(candidateAdviceMethod);
        if (aspectJAnnotation == null) {
            return null;
        }

        // If we get here, we know we have an AspectJ method.
        // Check that it's an AspectJ-annotated class
        if (!isAspect(candidateAspectClass)) {
            throw new AopConfigException("Advice must be declared inside an aspect type: " +
                    "Offending method '" + candidateAdviceMethod + "' in class [" +
                    candidateAspectClass.getName() + "]");
        }

        if (logger.isDebugEnabled()) {
            logger.debug("Found AspectJ method: " + candidateAdviceMethod);
        }

        AbstractAspectJAdvice springAdvice;

        switch (aspectJAnnotation.getAnnotationType()) {
            case AtBefore:
                springAdvice = new AspectJMethodBeforeAdvice(
                        candidateAdviceMethod, expressionPointcut, aspectInstanceFactory);
                break;
            case AtAfter:
                springAdvice = new AspectJAfterAdvice(
                        candidateAdviceMethod, expressionPointcut, aspectInstanceFactory);
                break;
            case AtAfterReturning:
                springAdvice = new AspectJAfterReturningAdvice(
                        candidateAdviceMethod, expressionPointcut, aspectInstanceFactory);
                AfterReturning afterReturningAnnotation = (AfterReturning) aspectJAnnotation.getAnnotation();
                if (StringUtils.hasText(afterReturningAnnotation.returning())) {
                    springAdvice.setReturningName(afterReturningAnnotation.returning());
                }
                break;
            case AtAfterThrowing:
                springAdvice = new AspectJAfterThrowingAdvice(
                        candidateAdviceMethod, expressionPointcut, aspectInstanceFactory);
                AfterThrowing afterThrowingAnnotation = (AfterThrowing) aspectJAnnotation.getAnnotation();
                if (StringUtils.hasText(afterThrowingAnnotation.throwing())) {
                    springAdvice.setThrowingName(afterThrowingAnnotation.throwing());
                }
                break;
            case AtAround:
                springAdvice = new AspectJAroundAdvice(
                        candidateAdviceMethod, expressionPointcut, aspectInstanceFactory);
                break;
            case AtPointcut:
                if (logger.isDebugEnabled()) {
                    logger.debug("Processing pointcut '" + candidateAdviceMethod.getName() + "'");
                }
                return null;
            default:
                throw new UnsupportedOperationException(
                        "Unsupported advice type on method: " + candidateAdviceMethod);
        }

        // Now to configure the advice...
        springAdvice.setAspectName(aspectName);
        springAdvice.setDeclarationOrder(declarationOrder);
        String[] argNames = this.parameterNameDiscoverer.getParameterNames(candidateAdviceMethod);
        if (argNames != null) {
            springAdvice.setArgumentNamesFromStringArray(argNames);
        }
        springAdvice.calculateArgumentBindings();
        return springAdvice;
    }
```

### 7.3.2 寻找匹配增强器

``` {.java}
        List<Advisor> eligibleAdvisors = findAdvisorsThatCanApply(candidateAdvisors, beanClass, beanName);


// 最终找到最合适的增强器在于
public static boolean canApply(Pointcut pc, Class<?> targetClass, boolean hasIntroductions) {
        Assert.notNull(pc, "Pointcut must not be null");
        if (!pc.getClassFilter().matches(targetClass)) {
            return false;
        }

        MethodMatcher methodMatcher = pc.getMethodMatcher();
        if (methodMatcher == MethodMatcher.TRUE) {
            // No need to iterate the methods if we're matching any method anyway...
            return true;
        }

        IntroductionAwareMethodMatcher introductionAwareMethodMatcher = null;
        if (methodMatcher instanceof IntroductionAwareMethodMatcher) {
            introductionAwareMethodMatcher = (IntroductionAwareMethodMatcher) methodMatcher;
        }

        Set<Class<?>> classes = new LinkedHashSet<>(ClassUtils.getAllInterfacesForClassAsSet(targetClass));
        classes.add(targetClass);
        for (Class<?> clazz : classes) {
            Method[] methods = ReflectionUtils.getAllDeclaredMethods(clazz);
            for (Method method : methods) {
                if ((introductionAwareMethodMatcher != null &&
                        introductionAwareMethodMatcher.matches(method, targetClass, hasIntroductions)) ||
                        methodMatcher.matches(method, targetClass)) {
                    return true;
                }
            }
        }

        return false;
    }
```

### 7.3.3 创建代理

-   在wrapIfNecessary当中获取增强器之后，开始创建代理

``` {.java}
// Create proxy if we have advice.
        Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);
        if (specificInterceptors != DO_NOT_PROXY) {
            this.advisedBeans.put(cacheKey, Boolean.TRUE);
            Object proxy = createProxy(
                    bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
            this.proxyTypes.put(cacheKey, proxy.getClass());
            return proxy;
        }

```

#### 创建代理

``` {.java}
    protected Object createProxy(Class<?> beanClass, @Nullable String beanName,
            @Nullable Object[] specificInterceptors, TargetSource targetSource) {

        if (this.beanFactory instanceof ConfigurableListableBeanFactory) {
            AutoProxyUtils.exposeTargetClass((ConfigurableListableBeanFactory) this.beanFactory, beanName, beanClass);
        }

        ProxyFactory proxyFactory = new ProxyFactory();
// 配置proxy属性
        proxyFactory.copyFrom(this);

// 处理proxy信息
        if (!proxyFactory.isProxyTargetClass()) {
            if (shouldProxyTargetClass(beanClass, beanName)) {
                proxyFactory.setProxyTargetClass(true);
            }
            else {
                evaluateProxyInterfaces(beanClass, proxyFactory);
            }
        }

// 拦截器转换增强器
        Advisor[] advisors = buildAdvisors(beanName, specificInterceptors);
        proxyFactory.addAdvisors(advisors);
        proxyFactory.setTargetSource(targetSource);
        customizeProxyFactory(proxyFactory);

        proxyFactory.setFrozen(this.freezeProxy);
        if (advisorsPreFiltered()) {
            proxyFactory.setPreFiltered(true);
        }

        return proxyFactory.getProxy(getProxyClassLoader());
    }


// 最终创建AOPproxy
    @Override
    public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
        if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
            Class<?> targetClass = config.getTargetClass();
            if (targetClass == null) {
                throw new AopConfigException("TargetSource cannot determine target class: " +
                        "Either an interface or a target is required for proxy creation.");
            }
            if (targetClass.isInterface() || Proxy.isProxyClass(targetClass)) {
                return new JdkDynamicAopProxy(config);
            }
            return new ObjenesisCglibAopProxy(config);
        }
        else {
            return new JdkDynamicAopProxy(config);
        }
    }

```

#### 两种代理模式

7.4 静态AOP示例
---------------

7.5 创建AOP静态代理
-------------------

-   静态代理：在jvm启动的时候通过改变目标对象字节码的方式来完成对目标对象的增强，比动态代理效率要高

### 7.5.1 Instrumentation

-   这玩意是一个接口，retransformClasses()这个方法可以将agent里面的代码动态添加到指定的类文件当中
-   需要在启动的时候添加java -javaagent:xxx.jar xxx类

