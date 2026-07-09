---
layout:         post
title:          vscode 同时 debug 多个程序
create_time:    2024-03-23 20:33
update_time:    
categories:     [Tools,Vscode]
---



以同时 `debug test_lzc.py` 和 `test_lzc_copy.py` （即 `run-test-1` 和 `run-test-2` 配置）为例



在 `launch.json` 文件新增如 `run-test-1` 和 `run-test-2` 以下配置



原理是针对要 debug 的指定 py 文件创建相应配置，而不是使用如 `"Python 调试程序: 当前文件"`  这种依赖同一配置



完整 `launch.json` 文件如下

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





然后正常使用 vscode debug 即可

![](/imgs/JeKyll/2024/2024-03-23-vscode-同时-debug-多个程序-001.png)



