---
date :  "2019-09-20T22:52:32+08:00" 
title : "Go源码分析(五)内存分配" 
categories : ["技术文章"] 
tags : ["go"] 
toc : true
---

### 内存模型



### 分配逻辑

入口在

```go
// src/runtime/malloc.go
// implementation of new builtin
// compiler (both frontend and SSA backend) knows the signature
// of this function
func newobject(typ *_type) unsafe.Pointer {
	return mallocgc(typ.size, typ, true)
}
```

`mgallocgc`里面主要看三个判断

```go
	c := gomcache()
	var x unsafe.Pointer
	noscan := typ == nil || typ.ptrdata == 0
	
	// maxSmallSize为32k
	if size <= maxSmallSize {
	  // 非指针，判断是否是小类型的对象，进行小类型分配 16byte
	  // 即mcache preP
		if noscan && size < maxTinySize {
					// Tiny allocator.
        // 若小于 16byte，则走preP
				if off+size <= maxTinySize && c.tiny != 0 {
          // The object fits into existing tiny block.
          x = unsafe.Pointer(c.tiny + off)
          c.tinyoffset = off + size
          c.local_tinyallocs++
          mp.mallocing = 0
          releasem(mp)
          return x
        }
			// Allocate a new maxTinySize block.
			// 走mspan的逻辑
			span := c.alloc[tinySpanClass]
		} else {
		  // 若不是小对象，则进入 mspan
			var sizeclass uint8
			// 获取大小判断使用37个span当中哪一个
			if size <= smallSizeMax-8 {
				sizeclass = size_to_class8[(size+smallSizeDiv-1)/smallSizeDiv]
			} else {
				sizeclass = size_to_class128[(size-smallSizeMax+largeSizeDiv-1)/largeSizeDiv]
			}
			size = uintptr(class_to_size[sizeclass])
			spc := makeSpanClass(sizeclass, noscan)
			// 分配内存
			span := c.alloc[spc]
			v := nextFreeFast(span)

			....
		}
	} else {
		// 大对象， 超过32k，进入largeAlloc，即mheap
		var s *mspan
		shouldhelpgc = true
		systemstack(func() {
			s = largeAlloc(size, needzero, noscan)
		})
		...
	}
```

