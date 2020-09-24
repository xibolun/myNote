---

date :  "2020-03-02T10:37:27+08:00" 
title : "Imagemagick使用" 
categories : ["技术文章"] 
tags : ["tools"] 
toc : true
---

## ImageMagick

> 最近有一批图片需要上传至阿里云，但是图片size太大了，超过了3M的要求；如果一个一个地转换比较麻烦，所以去搜索了一下，发现一个强大的批量处理工具––ImageMagick

#### 什么是imagemagick

ImageMagick是一个可以对图片进行创建、修改、压缩、转移的工具，支持多种图片格式 PNG, JPEG, GIF, HEIC, TIFF, DPX、EXR、 WebP, Postscript, PDF, and SVG；可以对图片进行大小调整、添加文字、线、图象、颜色等；并且还是开源的；

- 这里是一个它的官方[DEMO](https://imagemagick.org/script/examples.php)，可以对图片进行的处理功能后面的信息都放在这里；
- 这是它的所有特性：[Features and Capabilities](https://github.com/ImageMagick/ImageMagick#features-and-capabilities)

功能非常强大；在大批量处理图片的场景比PS等图像处理软件要好；

### Mac下使用

#### 安装

安装包下载完成后，需要更新一个xcode；最后把系统升级了一下搞定；

#### 工具列表

- convert：对图片进行压缩、分辨率、品质等属性的修改、转换
- idenitify：查看图片的信息、详情
- mogrify：批量处理图片、HDRI、品质、转换等；
- composite：覆盖图片
- montage：生成缩略图
- display：幻灯片播放
- animate：查看GIF动图
- compare：对比图片
- stream：对图片进行流处理
- import：
- conjure

所有的工具列表都在这里了 [basic_usage](https://legacy.imagemagick.org/Usage/basics/#cmdline)

以下是我自己使用的简单的两个场景：

#### 图片压缩

```shell
convert -quality 100 src -resize 1500x1125  target
```

自己写了一个脚本转换两个目录的文件

```shell
for i in $(ls 家具图片)
do
        convert -quality 100 家具图片/$i -resize 1500x1125  convert/$i
done
```

#### HEIC转jpg

```shell
mogrify -quality 100  -format jpg *.HEIC
```

