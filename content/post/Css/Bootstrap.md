---

date :  "2019-02-10T09:56:08+08:00" 
title : "Bootstrap" 
categories : ["技术文章"] 
tags : ["Css"] 
toc : true

---

### 滚动

[Bootstrap Carousel]: https://v3.bootcss.com/javascript/#carousel

- data-slide-to 每个滚动的图片的序号
- data-interval 设置默认循环滚动的间隔
- data-pause="hover" 当鼠标悬停的时候滚动停止
- class='active' 默认行路的carousel

```
<div id="carousel-example-generic" class="carousel slide" data-ride="carousel">
            <!-- Indicators -->
            <ol class="carousel-indicators">
                <li data-target="#carousel-example-generic" data-slide-to="0" class="active"></li>
                <li data-target="#carousel-example-generic" data-slide-to="1"></li>
                <li data-target="#carousel-example-generic" data-slide-to="2"></li>
                <li data-target="#carousel-example-generic" data-slide-to="3"></li>
            </ol>

            <!-- Wrapper for slides -->
            <div class="carousel-inner" role="listbox">
                <div class="item active">
                    <img src="http://idcos.com/public/assets/homepage/banner1.jpg" alt="">
                    <div class="carousel-caption">
                        <h1>IDCOS</h1>
                        <h3>数据中心操作系统</h3>
                        <p>云霁科技自主研发的国内第一个数据中心操作系统，是面向数据中心和IT运维部门的新一代PAAS平台，解决云计算数据中心在规模和效率上面临的挑战以及传统数据中心和用户转型云计算过程中遇到的困难。
                        </p>
                    </div>
                </div>
                <div class="item">
                    <img src="http://idcos.com/public/assets/homepage/banner2.jpg" alt="">
                    <div class="carousel-caption">
                        <h1>CloudRes</h1>
                        <h3>智能云管理平台</h3>
                        <p>新一代企业级laas云管理平台，实现传统设备和云化资源、私有云和公有云的统一管理，改变资源的交付模式；将传统的“设备交付”变为全自动的“服务交付”，通过服务目录和自服务的方式持续优化
                            IT 服务能力。</p>
                    </div>
                </div>
                <div class="item">
                    <img src="http://idcos.com/public/assets/homepage/banner3.jpg" alt="">
                    <div class="carousel-caption">
                        <h1>CloudRes</h1>
                        <h3>智能云管理平台</h3>
                        <p>新一代企业级laas云管理平台，实现传统设备和云化资源、私有云和公有云的统一管理，改变资源的交付模式；将传统的“设备交付”变为全自动的“服务交付”，通过服务目录和自服务的方式持续优化
                            IT 服务能力。</p>
                    </div>
                </div>
                <div class="item">
                    <img src="http://idcos.com/public/assets/homepage/banner4.jpg" alt="">
                    <div class="carousel-caption">
                        <h1>CloudRes</h1>
                        <h3>智能云管理平台</h3>
                        <p>新一代企业级laas云管理平台，实现传统设备和云化资源、私有云和公有云的统一管理，改变资源的交付模式；将传统的“设备交付”变为全自动的“服务交付”，通过服务目录和自服务的方式持续优化
                            IT
                            服务能力。</p>
                    </div>
                </div>
            </div>

        </div>
```

