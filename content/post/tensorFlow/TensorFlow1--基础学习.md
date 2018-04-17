## 什么是MNIST

MNIST是一个入门级的计算机视觉数据集，是机器学习的入门。





## TensorFlow安装

使用python3的virtualenv进行安装

```shell
(pyenv3) ➜  bin pip3 install --upgrade https://storage.googleapis.com/tensorflow/mac/tensorflow-0.8.0-py3-none-any.whl
Collecting tensorflow==0.8.0 from https://storage.googleapis.com/tensorflow/mac/tensorflow-0.8.0-py3-none-any.whl
  Downloading https://storage.googleapis.com/tensorflow/mac/tensorflow-0.8.0-py3-none-any.whl (19.3MB)
    100% |████████████████████████████████| 19.3MB 64kB/s 
Collecting numpy>=1.10.1 (from tensorflow==0.8.0)
  Downloading numpy-1.14.1-cp36-cp36m-macosx_10_6_intel.macosx_10_9_intel.macosx_10_9_x86_64.macosx_10_10_intel.macosx_10_10_x86_64.whl (4.7MB)

```

安装完成之后查看tensorflow目录

```shell
/Users/admin/projects/pyenv3/lib/python3.6/site-packages/tensorflow/models/image/mnist
```

其中/Users/admin/projects/pyenv3 是我的虚拟目录，开始训练MNIST数据集

```
(pyenv3) ➜  mnist python convolutional.py 
```



### 写程序做一下测试

```
(pyenv3) ➜  mnist bpython
bpython version 0.16 on top of Python 3.6.2 /Users/admin/projects/pyenv3/bin/python3.6
>>> import tensorflow
>>> import tensorflow as tf
>>> hello  = tf.constant('Hello, TensorFlow!')
>>> sess =tf.Session()
>>> sess.run(hello)
b'Hello, TensorFlow!'
>>> a = tf.constant(10)
>>> b = tf.constant(32)
>>> sess.run(a+b)
42
```

