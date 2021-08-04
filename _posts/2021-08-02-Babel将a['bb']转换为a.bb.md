---
layout:     post  
title:      Babel 将 a['bb'] 转换为 a.bb
date:       2021-08-02 20:03  
author:     maida  
categories: [Babel&nbsp;AST]  
tags:  
 - Babel
 - AST
 - nodejs
 - JavaScript

---


### 需求
将 js 代码中 `a['bb']` 形式转换为 `a.bb` 形式。  

**为什么需要这么做？**  
因为 `babel` 中 `path.evaluate()` 仅能运行 `a.bb` 形式

下面是代码样例(encode.js)  
```javascript
var array = '4|3|8|5|4|0|2|3'['split']('|');
var array = '4|3|8|5|4|0|2|3'.split('|');
```

处理后代码(decode.js)
```javascript
var array = '4|3|8|5|4|0|2|3'.split('|');
var array = '4|3|8|5|4|0|2|3'.split('|');
```

### 思路
在在线解析网站 [ast explorer](https://astexplorer.net/) 观察 `a['bb']` 和 `a.bb` 两种形式  

发现，二者都是 `MemberExpression` 节点，基本相同  
**区别如下：**
- `computed` 属性
- `property` 属性  

所以，构造替换相应节点即可，比较简单。

### 编写 babel 插件
完整插件代码如下  
```javascript
// decrypt.js
const fs = require('fs');
var util = require('util');
const parser = require('@babel/parser');
const traverse = require('@babel/traverse').default;
const types = require('@babel/types');
const generator = require('@babel/generator').default;

// 程序启动时间
var time_start = new Date().getTime()
// 读取文件
process.argv.length > 2 ? encode_file = process.argv[2] : encode_file = 'encode.js';
process.argv.length > 3 ? decode_file = process.argv[3] : decode_file = 'decode.js';

let jscode = fs.readFileSync(encode_file, { encoding: 'utf-8' });
console.log(util.format('Reading the file [%s] is complete.', encode_file))
// 转换为 ast 树
let ast = parser.parse(jscode);

const visitor =
{
    MemberExpression(path) {
        let { computed } = path.node;
        // 获取 path property 子路径
        let property = path.get('property');
        if (computed && types.isStringLiteral(property)) {
            property.replaceWith(types.identifier(property.node.value));
            path.node.computed=false;
        }
    }
}

//调用插件，处理待处理 js ast 树
traverse(ast, visitor);
console.log('AST traverse completed.')

// 生成处理后的 js
let { code } = generator(ast);
console.log('AST generator completed.')
fs.writeFile(decode_file, code, (err) => { });
console.log(util.format('The javascript code in [%s] has been processed.', encode_file))
console.log(util.format('The processing result has been saved to [%s].', decode_file))
// 程序结束时间
var time_end = new Date().getTime()
console.log(util.format('The program runs to completion, time-consuming: %s s', (time_end - time_start) / 1000))
```

### 推荐阅读
- [Babel AST 入门](/2021/07/27/Babel-AST入门.html)
- [Babel 小技巧](/2021/07/28/Babel-小技巧.html)
