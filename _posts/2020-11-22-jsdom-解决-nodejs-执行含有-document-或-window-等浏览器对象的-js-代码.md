---
layout:     post
title:      jsdom 解决 nodejs 执行含有 document 或 window 等浏览器对象的 js 代码
date:       2020-11-22 12:37
author:     maida
categories: [Python&nbsp;爬虫]
tags:
 - Python&nbsp;爬虫
 - nodejs
 - jsdom
---

## 环境需求
1. 已安装 nodejs ，[点此去安装](https://nodejs.org/zh-cn/download/)
2. 查看 node 模块全局路径，`npm -g root`
2. 在环境变量中添加 `NODE_PATH` 变量，值为上述 node 模块全局路径
3. 安装 jsdom ，以下是全局安装 jsdom （可在任意地方调用 jsdom ，不局限于执行安装命令时的路径）  
    ```bash
    npm -g install jsdom 
    ```

## 解决步骤
在 js 文件首部添加以下代码即可
```javascript
const jsdom = require("jsdom");
const {JSDOM} = jsdom;
const dom = new JSDOM(`<!DOCTYPE html><p>Hello world</p>`);
window = dom.window;
document = window.document;
navigator = window.navigator;
XMLHttpRequest = window.XMLHttpRequest;
```

## 推荐链接
1. [jsdom GitHub 地址](https://github.com/jsdom/jsdom)
2. [Ubuntu 安装 nodejs](https://nodejs.org/zh-cn/download/package-manager/#debian-and-ubuntu-based-linux-distributions-enterprise-linux-fedora-and-snap-packages)
3. [pycharm 运行 js](https://maida6244.xyz/2020/11/22/pycharm-%E8%BF%90%E8%A1%8C-js-%E4%BB%A3%E7%A0%81.html)