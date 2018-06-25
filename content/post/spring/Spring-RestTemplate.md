+++
date = "2017-04-27T23:36:24+08:00" title = "Spring-RestTemplate" categories = ["技术文章"] tags = ["spring"] toc = true
+++


解决中文乱码的问题和Delete无法传入body的问题
--------------------------------------------

问题说明：[RestTemplate中文乱码问题](http://www.cnblogs.com/accessking/p/Java.html#3659369)；
回复里面有我的评论，以下为解决方法

``` {.java}
package com.idcos.cloudres.biz.common.util;

import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpUriRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpMethod;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * restful 接口工具类
 * Created by guanbin on 2017/3/15.
 */
public class RestfulUtil {

    private static final Logger logger = LoggerFactory.getLogger(RestfulUtil.class);

    /**
     * 获取StringHttpMessageConverter字符集为utf-8类型的RestTemplate
     * @return
     */
    public static final RestTemplate getRestTemplate() {
        RestTemplate restTemplate = new RestTemplate();
        List<HttpMessageConverter<?>> converterList = restTemplate.getMessageConverters();
        HttpMessageConverter<?> converterTarget = null;
        for (HttpMessageConverter<?> item : converterList) {
            if (item.getClass() == StringHttpMessageConverter.class) {
                converterTarget = item;
                break;
            }
        }

        if (converterTarget != null) {
            converterList.remove(converterTarget);
        }
        HttpMessageConverter<?> converter = new StringHttpMessageConverter(StandardCharsets.UTF_8);
        converterList.add(1, converter);

        return restTemplate;
    }

    /**
     * 获取可以支持delete body的resttemplate
     * @return
     */
    public static RestTemplate getDeleteRestTemplate() {
        RestTemplate restTemplate = getRestTemplate();
        restTemplate.setRequestFactory(new HttpComponentsClientHttpRequestFactory() {
            @Override
            protected HttpUriRequest createHttpUriRequest(HttpMethod httpMethod, URI uri) {
                if (HttpMethod.DELETE == httpMethod) {
                    return new HttpEntityEnclosingDeleteRequest(uri);
                }
                return super.createHttpUriRequest(httpMethod, uri);
            }
        });
        return restTemplate;
    }

    public static class HttpEntityEnclosingDeleteRequest extends HttpEntityEnclosingRequestBase {

        public HttpEntityEnclosingDeleteRequest(final URI uri) {
            super();
            setURI(uri);
        }
        @Override
        public String getMethod() {
            return "DELETE";
        }
    }

}
```

RestTemplate请求添加token
-------------------------

### POST请求

``` {.java}
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON_UTF8);
        httpHeaders.add("access-token", "Bearer " + token);

        HttpEntity<String> entity = new HttpEntity(paramter, httpHeaders);

        return JSON.parseObject(restTemplate.postForObject(url.toString(), entity, String.class),
            CmdbResponse.class);
```

### GET请求

``` {.java}
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.setContentType(MediaType.APPLICATION_JSON_UTF8);
        httpHeaders.add("access-token", "Bearer " + token);

        HttpEntity<String> entity = new HttpEntity(null, httpHeaders);
        String url = flowUrl + "/wf/api/1.0/wf_proc_inst/" + procInsId + "?tenant_id=egfbank";

        return restTemplate.exchange(url, HttpMethod.GET, entity, CmdbResponse.class).getBody();

```
