---

date :  "2018-10-20T22:12:01+08:00" 
title : "Go--time" 
categories : ["技术文章","golang"] 
tags : ["golang"] 
toc : true
---


## Go time学习 ##

``` go

func Test_time(t *testing.T) {
	// current time
	fmt.Printf("current time : %s\n", time.Now())

	// format
	fmt.Printf("current time (ANSIC): %s\n", time.Now().Format(time.ANSIC))
	fmt.Printf("current time (Stamp): %s\n", time.Now().Format(time.Stamp))
	fmt.Printf("current time (RFC1123): %s\n", time.Now().Format(time.RFC1123))
	fmt.Printf("current time (UnixDate): %s\n", time.Now().Format(time.UnixDate))
	fmt.Printf("current time (YYYY-MM-DD): %s\n", time.Now().Format("2006-01-02"))
	fmt.Printf("current time (YYYY-MM-DD HH:mm:ss): %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("current time (YYYY-MM-DD HH:mm): %s\n", time.Now().Format("2006-01-02 15:04"))

	// year month day weekday
	fmt.Printf("yearday: %d\n", time.Now().YearDay())
	fmt.Printf("current Year: %d\n", time.Now().Year())
	fmt.Printf("current Month: %s\n", time.Now().Month())
	fmt.Printf("current Month(int): %d\n", time.Now().Month())
	fmt.Printf("current Day: %d\n", time.Now().Day())
	fmt.Printf("current Weekday: %s\n", time.Now().Weekday())
	fmt.Printf("current Weekday(int): %d\n", time.Now().Weekday())

	// 日子过了多少天
	fmt.Printf("日子过了多少天: %d\n", DayFromNow(time.Date(2015, 5, 8, 0, 0, 0, 0, time.Now().Location())))
	fmt.Printf("日子过了多少天: %d\n", DaySinceTime(time.Date(2015, 5, 8, 0, 0, 0, 0, time.Now().Location())))

	// string date to time
	fmt.Printf("string date to time %s\n", StrToTime("2018-05-08", "2006-01-02"))
	fmt.Printf("isEqual: %t\n", time.Now().Equal(time.Now())) //time.now两次是不相等的
	fmt.Printf("isEqual: %t\n", StrToTime("2018-05-08", "2006-01-02").Equal(StrToTime("2018-05-08", "2006-01-02")))

	startTime := time.Now()
	fmt.Printf("startTime is: %s\n", startTime)
	//time.Sleep(10 * time.Second)
	// sub time
	fmt.Printf("sub time: %f\n", time.Now().Sub(startTime).Seconds())
	fmt.Printf("isAfter: %t\n", time.Now().After(startTime))
	fmt.Printf("time add: %s\n", startTime.AddDate(1, 1, 1).Format("2006-01-02"))
	fmt.Printf("isBefore: %t\n", time.Now().Before(startTime))
	fmt.Printf("since from startTime: %f\n", time.Since(startTime).Seconds())
	fmt.Printf("time truncate: %s\n", startTime.Truncate(2*time.Hour))



}

func DayFromNow(t time.Time) int {
	return int(time.Now().Sub(t).Hours() / 24)
}

func DaySinceTime(t time.Time) int {
	return int(time.Since(t).Hours() / 24)
}

func StrToTime(str, layout string) time.Time {
	time2, _ := time.ParseInLocation(layout, str, time.Now().Location())
	return time2
}

func Test_Ticket(t *testing.T) {
	ticker := time.NewTicker(2 * time.Second)

	i := 0
	go func() {
		for { //循环
			<-ticker.C
			i++
			fmt.Println("i =", i)
			if i == 5 {
				ticker.Stop()
			}
		}
	}()
}

```



###  标准时间格式列表

- ```
  2006-01-02 15:04:05 +0800 CST
  ```