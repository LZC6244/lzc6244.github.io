---
layout:     post  
title:      删除未被使用的 function 和由 var,let,const 定义的未使用变量
date:       2021-07-28 20:43   
author:     maida  
categories: [Babel&nbsp;AST]  
tags:  
 - Babel
 - AST
 - nodejs
 - JavaScript

---


### 需求
删除未被使用的无用函数、变量，简化代码  

代码样例(encode.js)  
```javascript
var a = 1, b = 2, d, aa = 11;
let c = b + 3;
const f = 5;
console.log(aa);

function test_1() {
    console.log('I\'m test_1.');
}

function test_2() {
    console.log('I\'m test_2.');
}
test_2();
```

处理后代码(decode.js)
```javascript
var b = 2,
    aa = 11;
console.log(aa);

function test_2() {
  console.log('I\'m test_2.');
}

test_2();
```

### 思路
1. 通过 [ast explorer](https://astexplorer.net/) 在线解析网站对比可发现  
   - `function` 函数都是 `FunctionDeclaration`   
   - `var,let,const` 定义的变量节点类型都是 `VariableDeclarator` 
2. 有被使用/引用的函数、变量不做删除处理

### 编写 babel 插件
目标节点为 `FunctionDeclaration` 和  `VariableDeclarator`  
函数、变量的 **binding** 关系类似以下结构  
```javascript
{
  identifier: node,
  scope: scope,
  path: path,
  kind: 'var',

  referenced: true,
  references: 3,
  referencePaths: [path, path, path],

  constant: false,
  constantViolations: [path]
}
```
显然 `referenced` 为 `true` 则代表函数、变量被使用/引用  
<br>
故插件 visitor 可以写成如下  
```javascript
visitor =
{
  'VariableDeclarator|FunctionDeclaration'(path) {
    const { id } = path.node;
    let binding = path.scope.getBinding(id.name);
    if (binding.referenced) {
      return;
    }
    path.remove();
  }
}
```
<br>  

完整插件代码如下  
```javascript
// decrypt.js
const fs = require('fs');
const parser = require('@babel/parser');
const traverse = require('@babel/traverse').default;
const types = require('@babel/types');
const generator = require('@babel/generator').default;

// 读取文件
process.argv.length > 2 ? encode_file = process.argv[2] : encode_file = 'encode.js';
process.argv.length > 3 ? decode_file = process.argv[3] : decode_file = 'decode.js';

let jscode = fs.readFileSync(encode_file, { encoding: 'utf-8' });
// 转换为 ast 树
let ast = parser.parse(jscode);

const visitor =
{
  'VariableDeclarator|FunctionDeclaration'(path) {
    const { id } = path.node;
    let binding = path.scope.getBinding(id.name);
    if (binding.referenced) {
      return;
    }
    path.remove();
  }
}

//调用插件，处理待处理 js ast 树
traverse(ast, visitor);

// 生成处理后的 js
// let { code } = generator(ast);
let { code } = generator(ast, opts = { retainLines: true });
// 打印处理后的 js
console.log(code);
fs.writeFile(decode_file, code, (err) => { });
```

### 推荐阅读
- [AST 入门](/2021/07/27/AST入门.html)
- [Babel 小技巧](/2021/07/28/Babel-小技巧.html)

### 参考
- [Babel 手册 - Bindings](https://github.com/jamiebuilds/babel-handbook/blob/master/translations/zh-Hans/plugin-handbook.md#bindings%E7%BB%91%E5%AE%9A)