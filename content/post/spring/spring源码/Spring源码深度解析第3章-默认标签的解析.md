+++
date = "2017-08-15T23:36:24+08:00" title = "Spring源码深度解析第3章--默认标签的解析" categories = ["技术文章"] tags = ["spring"] toc = true
+++


3.1 bean标签的解析及注册
------------------------

-   DefaultBeanDefinitionDocumentReader.parseDefaultElement:解析的标签有四种：import,alias,beans,bean

``` {.java}
    private void parseDefaultElement(Element ele, BeanDefinitionParserDelegate delegate) {
        if (delegate.nodeNameEquals(ele, IMPORT_ELEMENT)) {
            importBeanDefinitionResource(ele);
        }
        else if (delegate.nodeNameEquals(ele, ALIAS_ELEMENT)) {
            processAliasRegistration(ele);
        }
        else if (delegate.nodeNameEquals(ele, BEAN_ELEMENT)) {
            processBeanDefinition(ele, delegate);
        }
        else if (delegate.nodeNameEquals(ele, NESTED_BEANS_ELEMENT)) {
            // recurse
            doRegisterBeanDefinitions(ele);
        }
    }
```

-   首先理解bean的解析,
    在默认的processDefaultElement里面处理Bean的definition逻辑如下：

``` {.java}
protected void processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) {
    // 根据element获取BeanDefinitionHolder，里面包括着bean的名称,alias数组列表及BeanDefinition
        BeanDefinitionHolder bdHolder = delegate.parseBeanDefinitionElement(ele);
        if (bdHolder != null) {
      // 查看此beanName下面是否存在子的定义，继续再解析一次
            bdHolder = delegate.decorateBeanDefinitionIfRequired(ele, bdHolder);
            try {
                // Register the final decorated instance.
        // 以下为真正开始注册beanDefinition
                BeanDefinitionReaderUtils.registerBeanDefinition(bdHolder, getReaderContext().getRegistry());
            }
            catch (BeanDefinitionStoreException ex) {
                getReaderContext().error("Failed to register bean definition with name '" +
                        bdHolder.getBeanName() + "'", ele, ex);
            }
            // Send registration event. 发送事件
            getReaderContext().fireComponentRegistered(new BeanComponentDefinition(bdHolder));
        }
    }

```

-   BeanDefinitionParserDelegate类当中有多个parseBeanDefinitionElement方法，是多态的
-   BeanDefinitionParserDelegate当中的parseBeanDefinitionElement首先会解析id和name，以及alias，然后调用真正解析其他属性的parseBeanDefinitionElement方法

``` {.java}
    public BeanDefinitionHolder parseBeanDefinitionElement(Element ele, BeanDefinition containingBean) {}
```

-   BeanDefinitionParserDelegate当中的parseBeanDefinitionElement下面的方法，会真正解析ele里面的Attribute,描述信息，元数据，Look-up,Construct，Qualifier,Property等信息

``` {.java}
public AbstractBeanDefinition parseBeanDefinitionElement(Element ele, String beanName, BeanDefinition containingBean) {}
```

-   解析完成之后会返回BeanDefinitionHolder，里面包涵着xml里面定义的bean的所有属性
-   调用BeanDefinitionReaderUtils.registerBeanDefinition方法进行注册

``` {.java}
BeanDefinitionReaderUtils.registerBeanDefinition(bdHolder, getReaderContext().getRegistry());
```

-   对应不同的Register去注册对应的bean信息；![](http://120.25.192.95:3000/spring/BeanDefinitionRegistry.png)
-   由于我是使用xmlbeanFactory的方式去实现，所以注册器会使用DefaultListableBeanFactory

``` {.java}
    public void registerBeanDefinition(String beanName, BeanDefinition beanDefinition)
            throws BeanDefinitionStoreException {
    oldBeanDefinition = this.beanDefinitionMap.get(beanName);
    //  是否已经注册
        if (oldBeanDefinition != null) {

    }else{
       if (hasBeanCreationStarted()) {
         synchronized (this.beanDefinitionMap) {
                    this.beanDefinitionMap.put(beanName, beanDefinition);
                    List<String> updatedDefinitions = new ArrayList<String>(this.beanDefinitionNames.size() + 1);
                    updatedDefinitions.addAll(this.beanDefinitionNames);
                    updatedDefinitions.add(beanName);
                    this.beanDefinitionNames = updatedDefinitions;
                    if (this.manualSingletonNames.contains(beanName)) {
                        Set<String> updatedSingletons = new LinkedHashSet<String>(this.manualSingletonNames);
                        updatedSingletons.remove(beanName);
                        this.manualSingletonNames = updatedSingletons;
                    }
                }else{
            //  private final Map<String, BeanDefinition> beanDefinitionMap = new ConcurrentHashMap<String, BeanDefinition>(256);
           this.beanDefinitionMap.put(beanName, beanDefinition);
                   this.beanDefinitionNames.add(beanName);
                   this.manualSingletonNames.remove(beanName);

       }
    }
    // 清除缓存信息
    if (oldBeanDefinition != null || containsSingleton(beanName)) {
            resetBeanDefinition(beanName);
        }
}
```

-   最终会将bean的名称和定义信息放入到ConcurrentHashMap当中

3.2 alias标签解析
-----------------

-   DefaultBeanDefinitionDocumentReader.processAliasRegistration方法解析alias标签并完成注册信息

``` {.java}
    protected void processAliasRegistration(Element ele) {
        String name = ele.getAttribute(NAME_ATTRIBUTE);
        String alias = ele.getAttribute(ALIAS_ATTRIBUTE);
        boolean valid = true;
        if (!StringUtils.hasText(name)) {
            getReaderContext().error("Name must not be empty", ele);
            valid = false;
        }
        if (!StringUtils.hasText(alias)) {
            getReaderContext().error("Alias must not be empty", ele);
            valid = false;
        }
        if (valid) {
            try {
      // 注册alias信息
                getReaderContext().getRegistry().registerAlias(name, alias);
            }
            catch (Exception ex) {
                getReaderContext().error("Failed to register alias '" + alias +
                        "' for bean with name '" + name + "'", ele, ex);
            }
            getReaderContext().fireAliasRegistered(name, alias, extractSource(ele));
        }
    }
```

-   注册器是SimpleAliasRegistry，继承了AliasRegistry

3.3 import标签解析
------------------

### import标签示例

``` {.xml}
    <import resource="classpath*:"></import>
    <import resource="http:"></import>
    <import resource="file:"></import>
```

-   将import标签当中的resource封装为Resource类，Resource可以包涵classpath，url，file对象
-   解析Resource，判断是相对路径还是绝对路径
-   根据Resource去loadBeanDefinitions
-   加载完成之后，通知监听器
    getReaderContext().fireImportProcessed(location, actResArray,
    extractSource(ele));

3.4 beans标签解析
-----------------

### beans标签示例

-   spring在解析的时候将beans标签定义为NESTED~BEANSELEMENT~="beans"
-   beans标签的属性非常的多，但是肯定是循环去解析，因为beans里面是一个一个的小bean

``` {.java}
protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
        if (delegate.isDefaultNamespace(root)) {
            NodeList nl = root.getChildNodes();
            for (int i = 0; i < nl.getLength(); i++) {
                Node node = nl.item(i);
                if (node instanceof Element) {
                    Element ele = (Element) node;
                    if (delegate.isDefaultNamespace(ele)) {
            //又回到默认解析的地方，去判断标签属性，再次进行解析
                        parseDefaultElement(ele, delegate);
                    }
                    else {
            //解析自定义标签
                        delegate.parseCustomElement(ele);
                    }
                }
            }
        }
        else {
            delegate.parseCustomElement(root);
        }
    }
```
