---
layout:     post  
title:      Babel 处理 path.evaluate 执行部分 js 全局函数失败
date:       2021-08-03 19:23  
author:     maida  
categories: [Babel&nbsp;AST]  
tags:  
 - Babel
 - AST
 - nodejs
 - JavaScript

---


### 解决方案
修改 bBbel 源码 `your_path\node_modules\@babel\traverse\lib\path\evaluation.js` 文件

修改的原始代码为 `const VALID_CALLEES = ["String", "Number", "Math"];`

修改示例：添加对 **parseInt** 的处理  
改行代码修改为：`const VALID_CALLEES = ["String", "Number", "Math", "parseInt"];`

### 推荐阅读
- [Babel GitHub evaluation.ts](https://github.com/babel/babel/blob/e0dc925bbe148022df6b43dd6965ebca661915fc/packages/babel-traverse/src/path/evaluation.ts#L5)
- [AST 入门](/2021/07/27/AST入门.html)
- [Babel 小技巧](/2021/07/28/Babel-小技巧.html)
