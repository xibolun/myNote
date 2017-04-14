什么是JWT?
----------

jwt的全称是JSON Web Token；JSON Web
Token是一个开源标准([rfc7519)](https://tools.ietf.org/html/rfc7519)，是一个轻量，携带着用户信息的json
Object对象，安全的进行服务器端与客户端交互；这个对象可以校验、信任，因为它由数字组成；
轻量：因为轻量，所以可以更好地放在httpheader里面，在服务器与客户端之间快速交互
携带用户信息：将用户的重要信息:userId，userName等放在jwt当中，不用再次从数据库当中获取

什么时候使用？
--------------

1.  需要认证:用户根据username、password登录后，使用jwt返回一个token给客户端，客户端在请求的时候将token放在http
    header当中给服务器端，服务器端校验token的合法性，然后处理请求的response

2.  用户信息被改变：

jwt的结构
---------

### 基本结构

由header、payload、sinature三部分组成，最终以xxx.yyy.zzz的形式拼接

### header

header由两部分组成：

-   type of token : JWT
-   加密算法: HMAC/SHA256/RSA

### payload

payload里面存放着用户的信息，可以使用claims进行复合拼装,claims由已定义、public、private三部分组成

-   resolved(已定义)：iss/exp/sub/aud
-   public:url信息
-   private:用户信息

payload当中的数据都可以由用户自行设置

### sinature

签名，根据header、payload和一个用户设置的密码(secret)，生成一个签名，最后将header，payload，sinature拼接成xxx.yyy.zzz形式

怎么使用（java）
----------------

pom.xml里面引入jwt

``` {.java}
<dependency>
 <groupId>io.jsonwebtoken</groupId>
 <artifactId>jjwt</artifactId>
 <version>0.7.0</version>
</dependency> 
```

``` {.java}
 public static void main(String[] args) {
     String secret = "password";
     String userId = "zhangsan";
     String userName = "张三";

     // 输出的jwt:eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ6aGFuZ3NhbiIsInVzZXJOYW1lIjoi5byg5LiJIn0.024kCUw4nodiXEdeOWtjWFn8u2eoh-DdfmLiXYgZs9g
     String jwt = Jwts.builder().setSubject(userId).signWith(SignatureAlgorithm.HS256, secret)
         .claim("userName", userName).compact();
     System.out.println(jwt);
     // 客户端将Jwt传递给服务器,服务器根据secret进行解密,可以对jwt进行校验,取数据
     Jws<Claims> claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(jwt);
     //header={alg=HS256},body={sub=zhangsan, userName=张三},signature=024kCUw4nodiXEdeOWtjWFn8u2eoh-DdfmLiXYgZs9g
     System.out.println(claims);

 }
```

由上面可以看出claims里面存放的数据由header、body、signature三部分组成
