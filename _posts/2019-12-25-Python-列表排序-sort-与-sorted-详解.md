---
layout:     post
title:      Python 列表排序 sort 与 sorted 详解
date:       2019-12-25 20:57
author:     maida
categories: [Python,爬虫]
tags:
 - Python
 - list
 - sort
 - sorted
---

### 一、介绍及简单使用
<br>sort 与 sorted 是 Python 内置的列表排序函数。

- sort  
<br>使用 `list.sort()` 会将 list 进行升序排序，返回 `NoneType` ，影响 list 本身，如

```text
In [8]: li=[1,5,3,2]

In [9]: li.sort()

In [10]: li
Out[10]: [1, 2, 3, 5]

In [11]: type(li.sort())
Out[11]: NoneType
```

- sorted  
<br>使用 `sorted(list)` 会将 list 进行升序排序，返回 `list` ，不影响 list 本身，如

```text
In [12]: li=[1,5,3,2]

In [13]: sorted(li)
Out[13]: [1, 2, 3, 5]

In [14]: type(sorted(li))
Out[14]: list

In [15]: li
Out[15]: [1, 5, 3, 2]
```

### 二、使用进阶
<br>上面简单介绍了对列表的简单排序，那么，如果列表中嵌套了列表或者是字典呢？
  
嵌套型列表如何进行排序？  

sort 与 sorted 中都含有一个参数 `key` ，用于自定义参数排序。  
`key` 参数接收的是一个函数，函数的接收参数是列表中的各个值，利用函数的返回值的 ASCII 码进行排序。  
**若嫌弃定义函数麻烦可以使用 `lambda` 匿名函数，复杂函数推荐**

例子如下：  

- 列表嵌套列表  

```text
In [30]: l1=[1,3]

In [31]: l2=[2,5]

In [32]: l3=[3,4]

In [33]: ll=[l1,l2,l3]

In [34]: ll
Out[34]: [[1, 3], [2, 5], [3, 4]]

# 定义一个返回列表最后一个元素的函数
In [35]: def a(l):
    ...:     return l[-1]
    ...:

# 根据嵌套列表的最后一个元素进行升序排序
In [36]: sorted(ll,key=a)
Out[36]: [[1, 3], [3, 4], [2, 5]]

In [37]: ll.sort(key=a)

In [38]: ll
Out[38]: [[1, 3], [3, 4], [2, 5]]

# 使用 lambda 根据嵌套列表的首个元素进行升序排序
In [39]: sorted(ll,key=lambda s: s[0])
Out[39]: [[1, 3], [2, 5], [3, 4]]

# 直接使用 Python 内建函数 len ，根据列表字符串长度进行升序排序
In [40]: sorted(['aaa','b','cc'],key=len)
Out[40]: ['b', 'cc', 'aaa']
```

- 嵌套字典  

```text
In [46]: d1={'a':1,'b':2}

In [47]: d2={'a':11,'b':1}

In [48]: d3={'a':10,'b':3}

In [49]: ld=[d1,d2,d3]

In [50]: ld
Out[50]: [{'a': 1, 'b': 2}, {'a': 11, 'b': 1}, {'a': 10, 'b': 3}]

In [51]: def get_b(d):
    ...:     return d.get('b')
    ...:

In [52]: sorted(ld,key=get_b)
Out[52]: [{'a': 11, 'b': 1}, {'a': 1, 'b': 2}, {'a': 10, 'b': 3}]

...
```

- 使用多个值进行排序
```text
In[2]: li=[[1,2],[1,1],[1,3],[0,4],[3,2]]
In[3]: sorted(li,key=lambda x:[x[0],x[1]])
Out[3]: [[0, 4], [1, 1], [1, 2], [1, 3], [3, 2]]
```

- 更多使用  
其余更复杂的使用不外乎 `key` 接收的函数更多的定义，此处不再列举
