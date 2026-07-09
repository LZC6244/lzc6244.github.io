---
layout:         post
title:          vscode debug 调试 docker 容器内程序 
create_time:    2024-03-23 20:33
update_time:    
categories:     [Tools,Vscode]
---

# docker

尚未实操，等待实操后补充，可以参考下面[文档](https://code.visualstudio.com/docs/containers/debug-common#_python)



# docker-compose

本处以 debug python 程序为例，其余请参考[文档](https://code.visualstudio.com/docs/containers/docker-compose#_debug)



1. 在 launch.json 文件新增以下 Remote Attach 配置，没有该文件则新增该 launch.json 文件

```JSON
{
    // 使用 IntelliSense 了解相关属性。 
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
    
        {
            "name": "Python Debugger: Remote Attach",
            "type": "debugpy",
            "request": "attach",
            "port": 5678,
            "host": "localhost",
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}",
                    "remoteRoot": "/app"
                }
            ]
        }
    ]
}
```



docker-compose 文件参考以下，重点关注 `command` 处

debugpy 处的 listen port 记得和上边 `Remote Attach` 配置的 `port` 对应

```YAML
version: '3.4'

services:
  pythonsamplevscodedjangotutorial:
    image: pythonsamplevscodedjangotutorial
    build:
      context: .
      dockerfile: ./Dockerfile
    command: ["bash", "-x", "-c", "pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && pip install debugpy && python -m debugpy --wait-for-client --listen 0.0.0.0:5678 manage.py runserver 0.0.0.0:8000 --nothreading --noreload"]
    ports:
      - 8000:8000
      - 5678:5678
```



参考文档

- [vscode docker debug](https://code.visualstudio.com/docs/containers/debug-common#_python)

- [vscode docker-compose debug](https://code.visualstudio.com/docs/containers/docker-compose#_adding-docker-compose-support-to-your-project)

- [github debugpy](https://github.com/microsoft/debugpy)



