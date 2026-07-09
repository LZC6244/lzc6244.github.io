---
layout:         post
title:          vscode 调试 python 库代码
create_time:    2024-10-13 20:03
update_time:    
categories:     [Tools,Vscode]
---




在 `launch.json` 文件调试配置中新增 `"justMyCode": false` ，样如下



```Plain Text
{
  // 使用 IntelliSense 了解相关属性。 
  // 悬停以查看现有属性的描述。
  // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python 调试程序: 当前文件",
      "type": "debugpy",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      # 信任第三方代码以进入 debug 断点
      "justMyCode": false
    },
    {
      "name": "run-test-1",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/.../test_lzc.py",
      "console": "integratedTerminal",
      "justMyCode": false
    },
    {
      "name": "run-test-2",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/.../test_lzc_copy.py",
      "console": "integratedTerminal",
      "justMyCode": false
    }
  ]
}
```

