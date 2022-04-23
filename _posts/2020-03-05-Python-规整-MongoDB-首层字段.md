---
layout:         post
title:          Python 规整 MongoDB 首层字段
create_time:    2020-03-05 23:26
author:         maida
categories:     [Python,爬虫]
tags:
 - Python
 - MongoDB
 - Variety
---

## 前言

在爬取网站时，由于对网站结构的不了解  
并不能在编写爬虫程序时  
便将爬取的所有字段确定下来

如：   
`A` 详情页含有字段 `a` `b` `c`  
`B` 详情页含有字段 `a` `b` `d`  
最终形成字段 `a` `b` `c` `d`

而此时我们又有需求：**将所有数据的字段进行规整统一化**

在这种情况下，虽然，我们单独去写 Python 程序，亦或是 使用 MongoDB 的 js  
都可以达到我们的目的

但是，二者都是**有弊端的**  
- `Python` ：脚本碰到数据量较大的情况下，脑阔痛哦
- `js` ：一个库得写一个 js 没有通用性，烦哦  


**难道就没有比较方便的方式（譬如结合它们）去做这件事情么？**

**有的！** 我们可以安装 `py_variety`

### py_variety 使用方式
```python
from py_variety import formal_fields

db_name = 'db_name'
coll_name = 'coll_name'
new_name = 'new_name'
formal_fields(host='x.x.x.x', verify={'user': 'xxx', 'passwd': 'xxxxxx', 'authdb': 'xxxx'},
              db_name=db_name, coll_name=coll_name,new_name=new_name)
```
方法正确执行将放回 `None` 且 打印处理后的集合名  
错误执行将返回错误信息（捕捉的终端报错信息）

### Github 项目地址
[https://github.com/LZC6244/py_variety](https://github.com/LZC6244/py_variety)