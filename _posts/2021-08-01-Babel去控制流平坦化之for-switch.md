---
layout:         post  
title:          Babel 去控制流平坦化之for-switch
create_time:    2021-08-01 17:53   
author:         maida  
categories:     [Babel&nbsp;AST]  
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
for (let index = '0'; index !== '11';) {
    switch (index) {
        case '0':
            console.log('This is case 0');
            index = '6';
            continue;
        case '1':
            console.log('This is case 1');
            index = '2';
            continue;
        case '2':
            console.log('This is case 2');
            index = '4';
            continue;
        case '3':
            index = '7';
            console.log('This is case 3');
            continue;
        case '4':
            console.log('This is case 4');
            index = '3';
            continue;
        case '5':
            console.log('This is case 5');
            continue;
        case '6':
            console.log('This is case 6');
            index = '9';
            continue;
        case '7':
            console.log('This is case 7');
            index = '10';
            continue;
        case '8':
            console.log('This is case 8');
            continue;
        case '9':
            console.log('This is case 9');
            index = '1';
            continue;
        default:
            index = '11';
            console.log('This is case [default], exit loop.');
    }
    break;
}
```

处理后代码(decode.js)
```javascript
console.log('This is case 0');
console.log('This is case 6');
console.log('This is case 9');
console.log('This is case 1');
console.log('This is case 2');
console.log('This is case 4');
console.log('This is case 3');
console.log('This is case 7');
console.log('This is case [default], exit loop.');
```

### 思路
还原前的代码执行逻辑大致是：  
- 利用 `index` 值控制整个 for-switch 的执行流程
- 最后 `index` 为 **'12'**， 跳出整个 for 循环  

**PS: index 值在每个 case 必然是会变更的，不然还原前的代码本身便是死循环了**

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
  ForStatement(path) {
    let { init, test, body } = path.node;
    if (!types.isVariableDeclaration(init) || !types.isBinaryExpression(test)) {
      return;
    }
    let declaration = init.declarations[0];

    const init_name = declaration.id.name;
    let init_value = declaration.init.value;
    let { left, operator, right } = test;

    if (!types.isIdentifier(left, { 'name': init_name }) || operator !== '!==') {
      return;
    }
    let test_value = right.value;

    let switch_statement = body.body[0];
    if (!types.isSwitchStatement(switch_statement)) {
      return;
    }
    let { discriminant, cases } = switch_statement;
    if (!types.isIdentifier(discriminant, { 'name': init_name })) {
      return;
    }
    // 存储 switch case 相关映射
    let case_map = {};
    // 存储最终代码语句节点
    let tmp_array = [];
    for (let c of cases) {
      let { consequent, test } = c, case_test_value;
      if (test) {
        case_test_value = test.value;
      }
      else {
        case_test_value = 'default_case';
      }
      case_map[case_test_value] = { 'new_init_value': null, 'statement_array': [] };
      for (let i of consequent) {
        if (types.isContinueStatement(i)) {
          continue;
        }
        if (types.isExpressionStatement(i) && types.isAssignmentExpression(i.expression)) {
          let left_name = i.expression.left.name;
          if (left_name !== init_name) {
            continue;
          }
          case_map[case_test_value]['new_init_value'] = i.expression.right.value;
          continue;
        }
        case_map[case_test_value]['statement_array'].push(i);
      }
    }

    while (true) {
      tmp_array = tmp_array.concat(case_map[init_value]['statement_array'])
      init_value = case_map[init_value]['new_init_value']

      if (init_value === test_value) {
        break;
      }

      if (!case_map[init_value]) {
        init_value = 'default_case';
      }
    }

    path.replaceWithMultiple(tmp_array);
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
- [去控制流平坦化之while-switch](/2021/07/30/去控制流平坦化之while-switch.html)
