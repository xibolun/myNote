---
date :  "2021-07-23 17:57:33+08:00"
title : "youtube-dl使用" 
categories : ["tool"] 
tags : ["tool"] 
toc : true
---

## youtube-dl使用

列出所有的格式

```
youtube-dl -F https://www.youtube.com/watch\?v\=THw7uNkHppM
```

下载指定格式的url

```
youtube-dl -f best https://www.youtube.com/watch\?v\=THw7uNkHppM
## +意味着使用ffmeg合并成一个文件
youtube-dl -f bestvideo+bestaudio https://www.youtube.com/watch\?v\=THw7uNkHppM

youtube-dl -f mp4 https://www.youtube.com/watch\?v\=THw7uNkHppM
```

下载多个

```
youtube-dl -f mp4 https://www.youtube.com/watch\?v\=THw7uNkHppM  https://www.youtube.com/watch?v=iJvr0VPsn-s
youtube-dl -a url.txt
```

下载重命名

```
youtube-dl -f mp4 https://www.youtube.com/watch\?v\=THw7uNkHppM -o 'a.mp4'
```

