+++
date = "2017-06-15T23:36:24+08:00" title = "Nginx学习" categories = ["技术文章"] tags = ["nginx"] toc = true
+++

Mac下nginx命令
--------------

``` {.shell}
sudo brew install nginx: brew安装nginx
/usr/local/etc/nginx/nginx.conf: nginx配置文件路径
sudo nginx：启动nginx
sudo nginx -s stop: 停止nginx
sudo nginx -s reload: 重启nginx

```

静态资源配置
------------

``` {.shell}
server {
    listen       4000;
    server_name  localhost;
    root   /home/www/christ;
    location / {
        autoindex on;
        autoindex_exact_size on;
        autoindex_localtime on;
    }
}
```
