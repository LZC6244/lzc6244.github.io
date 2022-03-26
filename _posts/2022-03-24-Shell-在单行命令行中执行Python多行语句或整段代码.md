---
layout:     post
title:      Shell 在单行命令行中执行 Python 多行语句/整段代码
date:       2022-03-24 20:32
author:     maida
categories: [Python,Shell]
tags:
 - Python
 - Shell
---
 
### 背景
在特定场景下

如我们需要在指定平台运行定时任务或执行脚本

但是该平台所配置的执行器我们无法选择使用指定版本/指定环境 Python 来执行脚本  

但此时该平台是可以使用 shell 来作为执行器的。

那么是否可以以此为突破口呢？

只要我们知道指定版本/指定环境 Python 的路径那肯定是 ok 的！


### 解决方案

首先，shell 中我们一般是这样运行 python 脚本的：`python test.py`  

那么，取个巧，我们把 `test.py` 做一下输入重定向不就行了？

需要考虑的是，由于 python 代码可能会存在换行啊单双引号等情况，我们怎么把它们优美地处理下。

经查阅，美化如下：
```shell
python << EOF

for i in rang(5):
    print(f'--- {i} ---')

if __name__ == '__main__':
    print(f'正常填入要执行的python代码即可')

EOF
```

至于剩下的给 shell 脚本添加 `# !/bin/bash` 头部之类的脚本细节这里就不补充了

都是些小问题 φ(゜▽゜*)♪

### 参考链接
- https://www.itranslater.com/qa/details/2126934330248266752
- https://www.runoob.com/linux/linux-shell-io-redirections.html