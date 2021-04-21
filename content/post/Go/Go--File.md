---

date :  "2018-12-07T22:20:32+08:00" 
title : "Go File学习" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true

---

## Go File学习

就写一个test方法

```go
func TestFile(t *testing.T) {
   dir := "/tmp/hello"
   path := "/tmp/hello.txt"
   // create dir
   os.Mkdir(dir, 0755)

   // create file
   file, _ := os.OpenFile(path, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)

   // filePath
   fmt.Printf("File.name(file full path): %v \n", file.Name())
   fmt.Println(filepath.Dir(file.Name()))
   fmt.Println(filepath.Abs(filepath.Dir(os.Args[0])))

   // current pwd
   pwd, err := os.Getwd()
   fmt.Printf("current pwd: %s\n", pwd)

   pwd, err = filepath.Abs("./")
   fmt.Printf("current pwd: %s\n", pwd)

   // exec path
   lookpath, _ := exec.LookPath(os.Args[0])
   fmt.Printf("exec path: %s\n", lookpath)

   // get file info
   fileInfo, err := file.Stat()
   fmt.Printf("%s\n", fileInfo.Name())

   // is exist
   if _, err := os.Stat("/tmp/bb.txt"); err != nil {
      if os.IsNotExist(err) {
         fmt.Printf("file is not exit\n")
      }
   }
   // is not exist       os.IsNotExist(err)
   // is permission   os.IsPermission(err)

   // ll命令
   if err = filepath.Walk(pwd, func(path string, info os.FileInfo, err error) error {
      fmt.Printf("%t %s %d %s %s\n", info.IsDir(), info.Mode(), info.Size(), info.ModTime().Format("2006-01-02 15:04:05"), info.Name())
      return nil
   }); err != nil {
      t.Error(err)
   }

   // relative path

   // mv dir

   // mv file

   // rename dir
   os.Rename(dir, "boot")

   // rename file
   os.Rename(file.Name(), "hello.txt")

   // write file
   err = ioutil.WriteFile(file.Name(), []byte("hello world"), 0644)
   if err != nil {
      t.Error(err)
   }

   // read file
   bytes, err := ioutil.ReadFile(file.Name())
   if err != nil {
      t.Error(err.Error())
   }
   fmt.Printf("file content: %s\n", string(bytes))

   // del dir
   os.RemoveAll(dir)

   // del file
   os.Remove(path)
}
```

#### 获取文件列表

```go

// GetFileList 获取目录下的文件列表
func GetFileList(dir, excludes string) []*os.File {
	var files []*os.File

	root, err := os.Open(dir)
	if err != nil {
		return files
	}
	fi, err := root.Stat()
	if err != nil {
		return files
	}
	if !fi.IsDir() {
		files = append(files, root)
		return files
	}

	fis, err := ioutil.ReadDir(dir)
	if err != nil {
		return files
	}

	for _, item := range fis {
		if strings.Index(excludes, item.Name()) != -1 {
			continue
		}
		fileFullPath := filepath.Join(dir, item.Name())

		if !item.IsDir() {
			f, _ := os.Open(fileFullPath)
			files = append(files, f)
			continue
		}
		files = append(files, GetFileList(fileFullPath, excludes)...)
	}
	return files
}
```

