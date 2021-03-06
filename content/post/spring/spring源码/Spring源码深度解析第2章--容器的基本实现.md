---

date :  "2017-08-03T23:36:24+08:00" 
title : "Spring源码深度解析第2章--容器的基本实现" 
categories : ["技术文章"] 
tags : ["spring"] 
toc : true
---


2.3 最简单的例子
----------------

``` {.java}
public class MyTestBean {

    private String testStr = "testStr";

    public String getTestStr() {
        return this.testStr;
    }

    public void setTestStr(String str) {
        this.testStr = str;
    }
}
```

``` {.xml}
<?xml version="1.0" encoding="UTF-8" ?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
         http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

    <bean id="myTestBean" class="com.spring.MyTestBean"/>

</beans>
```

``` {.java}
public class TestClass {

    @Test
    public void test() throws IOException {

        // ClassPathResource
        Resource res = new ClassPathResource("beanFactory.xml");

        BeanFactory beanFactory = new XBeanXmlBeanFactory(res);

        MyTestBean myTestBean = (MyTestBean) beanFactory.getBean("myTestBean");

        System.out.println(myTestBean.getTestStr());
    }
}

```

2.4 Spring核心类介绍
--------------------

![](http://120.25.192.95:3000/spring/beanfactory.png)

![](http://120.25.192.95:3000/spring/xmlBeanDefinitionReader.png)

2.5 容器的基础xmlBeanFactory
----------------------------

### 2.5.1 配置文件封装

-   IOC的第一步就是加载配置文件，获取配置文件的信息，去找到定义的对应的bean
-   Resource的作用是将配置文件资源进行统一封装，不管你是File/URL等配置，都统一封装为Resource，供BeanFactory使用
-   ![](http://120.25.192.95:3000/spring/resource.png)
-   FileSystemResource：需要给出文件的路径信息即可获取到文件的配置，因为实现上是调用了File.getInputStream()方法；或给出文件在classes当中的路径即可；
-   ClassPathResource：加载编译目录当中的配置文件，不需要路径信息，直接输入文件名称即可；若找不到，则去classes里面看文件是否存在，若不存在，需要配置到编译路径当中
-   UrlResource:
    可以访问file/http/ftp资源信息，可以通过获取某个类的classLoader即可得到对应的classes路径信息，就可以通过name来获取配置文件所在的路径的URL
-   ServletContextResource: 暂时不研究

``` {.java}
        //FileSystemResource
        Resource fileRes1 = new FileSystemResource(
            "/Users/admin/projects/myPro/src/resource/beanFactory.xml");
        Resource fileRes2 = new FileSystemResource("src/resource/beanFactory.xml");

        // ClassPathResource
        Resource classRes = new ClassPathResource("beanFactory.xml");

        // UrlResource
        //输出结果:/Users/admin/projects/myPro/target/classes/beanFactory.xml
        System.out.println(TestClass.class.getClassLoader().getResource("beanFactory.xml").getPath());

        Resource urlRes = new UrlResource(
            TestClass.class.getClassLoader().getResource("beanFactory.xml"));
```

### 2.5.2 加载bean

``` {.java}
        BeanFactory beanFactory = new XBeanXmlBeanFactory(res);
        MyTestBean myTestBean = (MyTestBean) beanFactory.getBean("myTestBean");
```

#### 封装资源文件

-   这个工作是由XmlBeanDefinitionReader完成的
-   首先封装Resource为EncodedResource，防止出现编码不一的情况，使用默认的encode；
-   然后再loadBeanDefinitions

``` {.java}
    public int loadBeanDefinitions(Resource resource) throws BeanDefinitionStoreException {
        return loadBeanDefinitions(new EncodedResource(resource));
    }
```

#### loadBeanDefinitions

``` {.java}
public int loadBeanDefinitions(EncodedResource encodedResource) throws BeanDefinitionStoreException {
        Assert.notNull(encodedResource, "EncodedResource must not be null");
        if (logger.isInfoEnabled()) {
            logger.info("Loading XML bean definitions from " + encodedResource.getResource());
        }

        Set<EncodedResource> currentResources = this.resourcesCurrentlyBeingLoaded.get();
        if (currentResources == null) {
            currentResources = new HashSet<>(4);
            this.resourcesCurrentlyBeingLoaded.set(currentResources);
        }
        if (!currentResources.add(encodedResource)) {
            throw new BeanDefinitionStoreException(
                    "Detected cyclic loading of " + encodedResource + " - check your import definitions!");
        }
        try {
            InputStream inputStream = encodedResource.getResource().getInputStream();
            try {
                InputSource inputSource = new InputSource(inputStream);
                if (encodedResource.getEncoding() != null) {
                    inputSource.setEncoding(encodedResource.getEncoding());
                }
                // 真正开始解析Bean的信息
                return doLoadBeanDefinitions(inputSource, encodedResource.getResource());
            }
            finally {
                inputStream.close();
            }
        }
        catch (IOException ex) {
            throw new BeanDefinitionStoreException(
                    "IOException parsing XML document from " + encodedResource.getResource(), ex);
        }
        finally {
            currentResources.remove(encodedResource);
            if (currentResources.isEmpty()) {
                this.resourcesCurrentlyBeingLoaded.remove();
            }
        }
    }

protected int doLoadBeanDefinitions(InputSource inputSource, Resource resource)
            throws BeanDefinitionStoreException {
        try {
      // 解析xml to Document
            Document doc = doLoadDocument(inputSource, resource);
      // 解析Document，注册Bean信息
            return registerBeanDefinitions(doc, resource);
        }
}
```

#### 解析xml

-   将EncodedResource转换为InputStream
-   将InputStream转换为InputSource
-   用SAX解析InputSource，获取Document，返回xml里面的Bean信息
-   获取EntityResolver；解析DTD文件的声明

``` {.java}
    protected EntityResolver getEntityResolver() {
        if (this.entityResolver == null) {
            // Determine default EntityResolver to use.
            ResourceLoader resourceLoader = getResourceLoader();
            if (resourceLoader != null) {
                this.entityResolver = new ResourceEntityResolver(resourceLoader);
            }
            else {
                this.entityResolver = new DelegatingEntityResolver(getBeanClassLoader());
            }
        }
        return this.entityResolver;
    }

```

-   解析InputSource的时候首先获取验证模式是XSD还是DTD

``` {.java}
protected int getValidationModeForResource(Resource resource) {
        int validationModeToUse = getValidationMode();
        if (validationModeToUse != VALIDATION_AUTO) {
            return validationModeToUse;
        }
        int detectedMode = detectValidationMode(resource);
        if (detectedMode != VALIDATION_AUTO) {
            return detectedMode;
        }
        return VALIDATION_XSD;
    }
```

#### 注册Bean信息

-   获取Document信息之后，第一步先取ROOT节点，再根据root节点，注册Bean的信息

``` {.java}
public void registerBeanDefinitions(Document doc, XmlReaderContext readerContext) {
        this.readerContext = readerContext;
        logger.debug("Loading bean definitions");
        Element root = doc.getDocumentElement();
        doRegisterBeanDefinitions(root);
    }

```

-   首先解析xml里面的profile，profile的作用做到环境隔离
-   然后解析root节点；
    parseDefaultElement解析的是Spring自带的标签，例如：bean,import,alias,beans；而parseCustomElement解析是用户自定义的标签，需要用户自己去写对应的实现；

``` {.java}
protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
        if (delegate.isDefaultNamespace(root)) {
            NodeList nl = root.getChildNodes();
            for (int i = 0; i < nl.getLength(); i++) {
                Node node = nl.item(i);
                if (node instanceof Element) {
                    Element ele = (Element) node;
                    if (delegate.isDefaultNamespace(ele)) {
                        parseDefaultElement(ele, delegate);
                    }
                    else {
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
