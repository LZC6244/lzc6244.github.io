---
layout:     post
title:      JeKyll 在 Windows 下本地预览中文路径
date:       2019-12-12 21:30
author:     maida
category: [JeKyll]
tags:
 - JeKyll
---

## 问题  

JeKyll（本文为`3.8`）支持 _post 目录下多级目录和中文路径  
（GitHub Pages + JeKyll 可正常使用）（非Windows系统）  

但在 `Windows` 本地预览时，若 `markdown` 文件名是中文的，会无法访问该文章（Markdown文件）（跳转到 JeKyll 404 页面）。  

## 解决方法

修改 `Ruby` 的 `filehandler.rb` 文件，若害怕误操作可以先备份。  
不知道该文件存放在哪可以使用 [Everything](https://www.voidtools.com/zh-cn/) 搜一下
- 查找 `filehandler.rb` 文件  
![查找filehandler.rb](/imgs/JeKyll/2019/12122130_01.png)
- 找到下方两段代码，并加入指定代码

```ruby
# 第一处
path = req.path_info.dup.force_encoding(Encoding.find("filesystem")
path.force_encoding("UTF-8") # 加入的代码
if trailing_pathsep?(req.path_info)  

# 第二处
break if base == "/"
base.force_encoding("UTF-8") # 加入的代码
break unless File.directory?(File.expand_path(res.filename + base))
```

![第一处](/imgs/JeKyll/2019/12122130_02.png)  
![第二处](/imgs/JeKyll/2019/12122130_03.png)
- 重启 JeKyll 

```bash
jekyll clean && jekyll serve
```

![效果图](/imgs/JeKyll/2019/12122130_04.png)