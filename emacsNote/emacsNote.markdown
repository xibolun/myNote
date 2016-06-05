### 常用操作 ###

* C-d 删除当前字符
* E-d 删除下一个单词
* C-k 删除当前行
* C-y 粘贴最近删除或复制的文本
* C-w 删除文本块
* E-w 复制文本
* C-x u 撤销
* C-x f 查询文件，支持tab补全
* C-s 查询文件当中的内容

### 光标操作 ###

* C-p 上一行
* C-n 下一行
* C-f 下一个字符
* C-b 上一个字符
* C-v 下一页
* E-v 上一页
* C-x [ 回到文件首
* C-x ] 回到文件尾


### 进阶操作 ###

* C-t 当前字符与前一字符交换位置
* E-t 当前字符，段落，文本与前一字符，段落，文本交换位置
* C-x C-u 区域转大写
* C-x C-l 区域转小写
* M-u 单词转大写
* M-l 单词转小写
* M-c 首字母大写
* C-g 撤销命令
* C-u M-! date插入当前的时间
* C-x C-h 全选

### 窗口操作 ###
* C-x 2 横向分屏
* C-x 3 纵向分屏
* C-x 0 关闭屏幕
* C-x o 切换屏幕
* C-x {} 窗口分隔线向左/右移动一次
* C-u 数字 C-x {} 窗口分隔线向左/右移动N次

### Markdown模式  ###

#### 配置Markdown ####

参考：http://jblevins.org/projects/markdown-mode/

1. 下载markdown-mode.el至emacs的启动目录，我设置为~/.emacs.d/plugins
2.  在~/.emacs目录当中添加以下脚本设置

`
(add-to-list 'load-path "~/.emacs.d/plugins")
(autoload 'markdown-mode "markdown-mode.el"
"Major mode for editing Markdown files" t)
(setq auto-mode-alist
(cons '(".markdown" . markdown-mode) auto-mode-alist))
`
3. emacs打开xx.markdown文件就会显示为Markdown模式


#### Markdown 常用快捷键 ####
* C-c C-t 1 设置1级标题
* C-c C-t   设置标题
* C-c --    修改标题等级与M-left/right功能相同
* C-c C-s c `设置代码片段`
* C-c C-s s **设置字体加粗**
* C-c C-s e *设置字体斜体*
* C-c C-c e 导出为name.html
* C-c C-c p 导出预览
* C-c C-a l 添加链接
* C-c C-a u 添加url
* C-c -     添加一条虚线
* C-c C-n/p 在标题之间下上移动
* C-c C-u   移动至当前标题的父标题
* C-c C-b/f 在同级标题之间上下移动

Emacs设置颜色，字体：http://blog.csdn.net/liufengl138/article/details/19838753





