---
layout:     post  
title:      还原由 var,let,const 定义的未变更的字面量  
date:       2021-07-29 20:30   
author:     maida  
categories: [Babel&nbsp;AST]  
tags:  
 - Babel
 - AST
 - nodejs
 - JavaScript

---


### 需求
还原由 `var,let,const` 定义的未变更的字面量，使得代码更直观

代码样例(encode.js)  
```javascript
var a = 1, b = 2;
b += 1;
let c = 3;
const d = 4;
let e = f(5, a, b, c, d);
let g = a + b + c;
```

处理后代码(decode.js)
```javascript
var b = 2;
b += 1;
let e = f(5, 1, b, 3, 4);
let g = 1 + b + 3;
```

### 思路
首先，明确需要处理的目标为**字面量**，即节点类型为 `Literal`  

其次，字面量**不能被修改**，修改的话你不知道使用字面量的时候到底是修改前还是后  

然后，根据字面量的作用域看下它在哪被使用了，进行相应节点替换  

最后，删除被替换的字面量节点

### 编写 babel 插件
直接上完整插件代码  
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
  VariableDeclarator(path) {
    const { id, init } = path.node;
    let binding = path.scope.getBinding(id.name);

    // 只处理字面量，且被修改则不作处理
    if (!types.isLiteral(init) || !binding.constant) {
      return;
    }
    for (let refer_path of binding.referencePaths) {
      refer_path.replaceWith(init);
    }
    path.remove();
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
- [AST 入门](/2021/07/27/AST入门.html)
- [Babel 小技巧](/2021/07/28/Babel-小技巧.html)

### 参考
- [Babel 手册 - Bindings](https://github.com/jamiebuilds/babel-handbook/blob/master/translations/zh-Hans/plugin-handbook.md#bindings%E7%BB%91%E5%AE%9A)
- `@babel/types` 文档中的 [Literal](https://babeljs.io/docs/en/babel-types#literal)