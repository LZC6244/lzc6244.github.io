---
layout:         post
title:          vscode 解决 python 导入第三方库波浪线/无法导入解析/reportMissingImports
create_time:    2024-08-03 20:13
update_time:    
categories:     [Docker]
---


# 解决方法

首先检查 vscode 右下方 python 环境是否选择正确

![](/imgs/JeKyll/2024/2024-08-03-vscode-解决-python-导入第三方库波浪线-无法导入解析-reportMissingImports-001.png)



若已选择正确仍然存在黄色波浪线无法跳转第三方库



在 vscode settings.json 文件中添加以下内容，指定当前项目使用 python 环境

```bash
# 样例 1
"python.envFile": "${workspaceFolder}/.venv",

# 样例 2
"python.envFile": "${workspaceFolder}/conda_venv",

```



重启 vscode 生效，remote ssh 的话断开重连即可生效

# 参考文档

- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#reportMissingImports



