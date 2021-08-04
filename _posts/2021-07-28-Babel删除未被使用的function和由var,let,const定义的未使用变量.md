---
layout:     post  
title:      Babel 删除未被使用的 function 和由 var,let,const 定义的未使用变量
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

function g() {
    var g = 1;
    g += 1;
    g += 1;
    console.log('g is ' + g)
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
**但是**，有这么一种特殊情况，若是函数中存在变量与函数名相同，且该变量被使用/引用  
那么按照上述的处理方式该函数若是未被使用是**不会被删除**的  
使用 `path.scope.dump()` 可以看到按此方式获取 binding 显然 `g` 函数是被“使用”了的  
![path-scope-dump](/imgs/JeKyll/2021/07282043_01.png)  
因为我们现在所处的作用域是函数作用域  
所以我们要判断该函数是否被使用应该从程序（program）作用域出发  
如下吗，即可正确获取函数是否被使用情况  
![path-scope-dump](/imgs/JeKyll/2021/07282043_02.png)  
<br>  

故，最终、完整插件代码如下  
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
    const { id } = path.node;
    let binding = path.scope.getBinding(id.name);

    if (binding.referenced) {
      return;
    }
    path.remove();
  },
  FunctionDeclaration(path) {
    const { id } = path.node;
    // 防止函数中存在变量与函数名相同，切该变量在函数中使用，导致未去除未使用函数
    let binding = path.scope.parent.getBinding(id.name);

    if (binding.referenced) {
      return;
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
- [Babel AST 入门](/2021/07/27/Babel-AST入门.html)
- [Babel 小技巧](/2021/07/28/Babel-小技巧.html)
- `path.scope.getBinding` 源码（显然自下而上遍历）
   ```javascript
   getBinding(name) {
       let scope = this;
       let previousPath;
   
       do {
         const binding = scope.getOwnBinding(name);
   
         if (binding) {
           var _previousPath;
   
           if ((_previousPath = previousPath) != null && _previousPath.isPattern() && binding.kind !== "param") {} else {
             return binding;
           }
         }
   
         previousPath = scope.path;
       } while (scope = scope.parent);
     }
   ```
- `path.scope.dump` 源码（显然自下而上遍历）
   ```javascript
   dump() {
       const sep = "-".repeat(60);
       console.log(sep);
       let scope: Scope = this;
       do {
         console.log("#", scope.block.type);
         for (const name of Object.keys(scope.bindings)) {
           const binding = scope.bindings[name];
           console.log(" -", name, {
             constant: binding.constant,
             references: binding.references,
             violations: binding.constantViolations.length,
             kind: binding.kind,
           });
         }
       } while ((scope = scope.parent));
       console.log(sep);
     }
   ```


### 参考
- [Babel 手册 - Bindings](https://github.com/jamiebuilds/babel-handbook/blob/master/translations/zh-Hans/plugin-handbook.md#bindings%E7%BB%91%E5%AE%9A)