---
layout:     post  
title:      Babel 去控制流平坦化之while-switch
date:       2021-07-30 21:11   
author:     maida  
categories: [Babel&nbsp;AST]  
tags:  
 - Babel
 - AST
 - nodejs
 - JavaScript

---


### 需求
控制流平坦化，大致就是把自上而下执行的代码通过控制的方式（比如while-switch,for-switch）打乱布局顺序

在不改变代码功能的情况下，给分析代码增加难度

具体解释、图解什么的请搜索引擎走起

下面是代码样例(encode.js)  
```javascript
var array = '4|3|8|5|4|0|2|3'.split('|'), index = 0;

while (true) {
    switch (array[index++]) {
        case '0':
            console.log('This is case 0');
            continue;
        case '1':
            console.log('This is case 1');
            continue;
        case '2':
            console.log('This is case 2');
            continue;
        case '3':
            console.log('This is case 3');
            continue;
        case '4':
            console.log('This is case 4');
            continue;
        case '5':
            console.log('This is case 5');
            continue;
        case '6':
            console.log('This is case 6');
            continue;
        case '7':
            console.log('This is case 7');
            continue;
        case '8':
            console.log('This is case 8');
            continue;
        case '9':
            console.log('This is case 9');
            continue;
        default:
            console.log('This is case [default], exit loop.');
    }
    break;
}
```

处理后代码(decode.js)
```javascript
var array = '4|3|8|5|4|0|2|3'.split('|'),
    index = 0;
console.log('This is case 4');
console.log('This is case 3');
console.log('This is case 8');
console.log('This is case 5');
console.log('This is case 4');
console.log('This is case 0');
console.log('This is case 2');
console.log('This is case 3');
console.log('This is case [default], exit loop.');
```

### 思路
还原前的代码执行逻辑大致是：  
- 利用 `array[index++]` 数组下标控制整个 while-switch 的执行流程
- 最后 `array[index++]` 为 **undefined**， 跳出整个 while 循环  

### 编写 babel 插件
废话不多说，完整插件代码  
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
  WhileStatement(path) {
    let { body } = path.node;
    let switch_statement = body.body[0];
    if (!types.isSwitchStatement(switch_statement)) {
      return;
    }
    let { discriminant, cases } = switch_statement;
    // 进一步进行特征判断
    if (!types.isMemberExpression(discriminant) || !types.isUpdateExpression(discriminant.property)) {
      return;
    }

    // 找到 array 是哪定义的，并且使用 path.evaluate() 方法获取其最终值
    let { confident, value } = path.scope.getBinding(discriminant.object.name).path.get('init').evaluate();

    if (!confident) {
      return;
    }
    let array = value, case_map = {}, tmp_array = [];

    for (let c of cases) {
      let { consequent, test } = c;
      let test_value;
      if (test) {
        test_value = test.value;
      }
      else {
        test_value = 'default_case';
      }
      let statement_array = [];
      for (let i of consequent) {
        if (types.isContinueStatement(i)) {
          continue;
        }
        statement_array.push(i);
      }
      case_map[test_value] = statement_array;
    }
    for (let i of array) {
      tmp_array = tmp_array.concat(case_map[i])
    }
    if (case_map.hasOwnProperty('default_case')) {
        tmp_array = tmp_array.concat(case_map['default_case'])
    }
    path.replaceWithMultiple(tmp_array);
    // 手动更新 scope ，防止影响下个插件使用
    path.scope.crawl();
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
- [Babel 去控制流平坦化之for-switch](/2021/08/01/Babel去控制流平坦化之for-switch.html)

### 参考
- [Babel 手册 - Bindings](https://github.com/jamiebuilds/babel-handbook/blob/master/translations/zh-Hans/plugin-handbook.md#bindings%E7%BB%91%E5%AE%9A)