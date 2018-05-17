+++
date = "2018-05-16T21:08:01+08:00" title = "RESTful与HTTP" categories = ["技术文章"] tags = ["软件思想"] toc = true
+++

## RESTful与HTTP

[RESTful wiki](https://en.wikipedia.org/wiki/Representational_state_transfer)

### 命名

- 名词而非动词，uri做为resource存在，做查询、修改、删除、新增操作；所以uri一般为名词，而非动词；
- 区分单复数； users与user不一样
- 可以将版本放入url当中，对url进行有效的版本区分
- 分页与排序可以做为queryParams进行处理



#### 其他公司的REST api设计

[openstack api](https://docs.openstack.org/queens/api/)

[github v3](https://developer.github.com/v3/#parameters)

### Relationship between URL and HTTP methods

| Uniform Resource Locator (URL)                              | GET                                                          | PUT                                                          | PATCH                                             | POST                                                         | DELETE                                             |
| ----------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------- |
| Collection, such as `https://api.example.com/resources/`    | **List** the URIs and perhaps other details of the collection's members. | **Replace** the entire collection with another collection.   | Not generally used                                | **Create** a new entry in the collection. The new entry's URI is assigned automatically and is usually returned by the operation. | **Delete** the entire collection.                  |
| Element, such as `https://api.example.com/resources/item17` | **Retrieve** a representation of the addressed member of the collection, expressed in an appropriate Internet media type. | **Replace** the addressed member of the collection, or if it does not exist, **create**it. | **Update**the addressed member of the collection. | Not generally used. Treat the addressed member as a collection in its own right and **create** a new entry within it. | **Delete** the addressed member of the collection. |
| 安全性与幂等性                                              | 安全幂等                                                     | 不安全幂等                                                   | 不安全幂等                                        | 不安全不幂等                                                 | 不安全幂等                                         |

注意：

- GET、POST、DELETE、PUT的restful的uri可以是相同的
- PATCH在Collection的操作当中没有使用，只在单个资源当中使用



[HTTP/1.1](https://www.w3.org/Protocols/rfc2616/rfc2616.html)