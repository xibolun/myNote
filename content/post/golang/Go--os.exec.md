---
date :  "2021-12-29 10:11:23+08:00"
title : "Go os.exec" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
description: golang commandContext can not cancel bash script
toc : true
---

## Go os.exec

golang基础的执行命令操作如下

- [基础命令执行](https://github.com/xibolun/GOTest/blob/e5a6cbde37e5266b83c6fb255bfb4de6fef17750/basic/exec_test.go?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L12)

```go
func TestSingleCommand(t *testing.T) {
	stdout, err := exec.Command("uname", "-a").CombinedOutput()
	if err != nil {
		t.Error(err)
		return
	}
	t.Log(stdout)
}
```

- [基础超时操作](https://github.com/xibolun/GOTest/blob/e5a6cbde37e5266b83c6fb255bfb4de6fef17750/basic/exec_test.go?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L21)

```go
func TestSingleTimeoutCommand(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	stdout, err := exec.CommandContext(ctx, "ping", "-c 2", "-i 1", "www.baidu.com").CombinedOutput()
	if err != nil {
		t.Error(err)
		return
	}
	t.Log(string(stdout))
}
```

- [长ping操作](https://github.com/xibolun/GOTest/blob/e5a6cbde37e5266b83c6fb255bfb4de6fef17750/basic/exec_test.go?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L33)

```go
// can not get stdout
//
// === RUN   TestSingleTimeoutCommand
//    exec_test.go:27: signal: killed
func TestLongTimeoutCommand(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	stdout, err := exec.CommandContext(ctx, "ping", "www.baidu.com").CombinedOutput()
	if err != nil {
		t.Error(err)
		return
	}
	t.Log(stdout)
}
```

> 注意，这样的操作，进行会被kill掉，无法获取stdout信息

基于上面的代码我们做一下改造，把`ping www.baidu.com`放在`/tmp/a.sh`当中，然后使用`/bin/bash`去执行

- [脚本执行，超时无法取消](https://github.com/xibolun/GOTest/blob/e5a6cbde37e5266b83c6fb255bfb4de6fef17750/basic/exec_test.go?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L49)

```go
// can not cancel when timeout
// cat /tmp/a.sh
// 		ping www.baidu.com
//
// === RUN   TestSingleTimeoutCommand
//    exec_test.go:27: signal: killed
func TestTimeoutCancelFailureCommand(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	stdout, err := exec.CommandContext(ctx, "/bin/bash", "/tmp/a.sh").CombinedOutput()
	if err != nil {
		t.Error(err)
		return
	}
	t.Log(stdout)
}
```

 这个原因是为什么呢？两个有什么区别？使用`pstree`看一下进程信息如下：

```shell
/bin/bash /tmp/a.sh

pstree
 |-+= 05392 pgy tmux
 | |-+= 05393 pgy -zsh
 | | \-+= 70797 pgy /bin/bash /tmp/a.sh
 | |   \--- 70798 pgy ping www.baidu.com
 
 
 ping www.baidu.com
 
 pstree
 |-+= 05392 pgy tmux
 | |-+= 05393 pgy -zsh
 | | \--= 70841 pgy ping www.baidu.com
```

由于我本地使用了`tmux`和`zsh`，所有执行信息都是从这两个里面`fork`出来，可以发现使用`bash`执行和直接命令执行的区别在于，`bash`会认为是多条命令在执行，会`fork`一个进程出来，而使用`ping`命令直接执行并不会`fork`；

这个区别对`golang`有什么影响呢？翻翻官网的issues：

- `windows`平台：https://github.com/golang/go/issues/22381#issuecomment-368114949
- 一个比较详细的解释：https://github.com/golang/go/issues/18874#issuecomment-277272067

- 一位博主的图

![golang cmd](https://chunlife.top/2019/03/22/go%E6%89%A7%E8%A1%8Cshell%E5%91%BD%E4%BB%A4/1553186402784.png)



由图中可以看到，当`golang`的`exec`执行`fork`类型的任务时，会将`stdout`、`stderr`放至`pipe`当中；而`timeout context`执行完后，无法做到回收子进程，所以整个程序被`hang`住；那如何做到优雅退出，并拿回`stdout`、`stderr`呢，需要手工从`pipe`当中获取无法使用`CombinedOutput`方法，因为此方法只会获取父进程的`pipe`；

所以[整体的代码](https://github.com/xibolun/GOTest/blob/f49e41758290c5087fb0f84053e7915429bb1e22/basic/exec_test.go?_pjax=%23js-repo-pjax-container%2C%20div%5Bitemtype%3D%22http%3A%2F%2Fschema.org%2FSoftwareSourceCode%22%5D%20main%2C%20%5Bdata-pjax-container%5D#L71)如下：

```go
// cancel command && get stdout\ stderr
// cat /tmp/a.sh
// 		ping www.baidu.com
//
// === RUN   TestSingleTimeoutCommand
//    exec_test.go:27: signal: killed
func TestTimeoutCancelCommand(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "/bin/bash", "/tmp/a.sh")

	stdoutPipe, _ := cmd.StdoutPipe()
	stderrPipe, _ := cmd.StderrPipe()

	outReader := bufio.NewReader(stdoutPipe)
	errReader := bufio.NewReader(stderrPipe)

	stdoutChan := make(chan string, 0)
	stderrChan := make(chan string, 0)

	err := cmd.Start()
	if err != nil {
		fmt.Println(err.Error())
		return
	}

	go func() {
		for {
			line, err := outReader.ReadString('\n')

			if line != "" {
				stdoutChan <- line
			}

			if err != nil {
				stderrChan <- err.Error()
				return
			}

			if line == "" {
				break
			}
		}
	}()
	go func() {
		for {
			line, err := errReader.ReadString('\n')

			if line != "" {
				stderrChan <- line
			}

			if err != nil {
				stderrChan <- err.Error()
				return
			}

			if line == "" {
				break
			}
		}
	}()

	var stdoutStr string
	var stderrStr string
LoopBreak:
	for {
		select {
		case <-ctx.Done():
			break LoopBreak
		case str := <-stdoutChan:
			stdoutStr += str
		case str := <-stderrChan:
			stderrStr += str
		}
	}

	err = cmd.Wait()
	if err != nil {
		exitErr := err.(*exec.ExitError)
		status := exitErr.Sys().(syscall.WaitStatus)
		if status.ExitStatus() == 0 {
			fmt.Printf("wrong exit status: %v", status.ExitStatus())
		}
	}

	fmt.Println(stdoutStr)
	fmt.Println(stderrStr)
	fmt.Println("exec done")
}
```

### 关于管道操作

管道操作不要使用CombinedOutput，会将stderr重定向至stdout当中；看如下几个测试用例

- [执行一个不存在的文件](https://github.com/xibolun/GOTest/blob/master/basic/exec_test.go#L240)，output不为空，而是stderr的值
- [加一下管道操作会怎么样呢？](https://github.com/xibolun/GOTest/blob/master/basic/exec_test.go#L259)  stdout为空了，而error有了数值，因为fork去执行了
- [把stderr放出来 呢?](https://github.com/xibolun/GOTest/blob/master/basic/exec_test.go#L267)，可以看到这个时候stdout\stderr都为nil，因为fork去执行报错了
- [使用bash执行呢？](https://github.com/xibolun/GOTest/blob/master/basic/exec_test.go#L280)，可以看到这个时候的执行才符合stdout\stderr

### 参考

- https://razeencheng.com/posts/simple-use-go-exec-command/
- https://chunlife.top/2019/03/22/go%E6%89%A7%E8%A1%8Cshell%E5%91%BD%E4%BB%A4/

