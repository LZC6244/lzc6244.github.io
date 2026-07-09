---
layout:         post
title:          xinference 部署
create_time:    2026-01-24 19:02
update_time:    
categories:     [Other]
---


# 概要

xinference 版本：0.16.1



## 权限

目前，Xinference 内部定义了以下几个接口权限：

- `models:list`: 获取模型列表和信息的权限。

- `models:read`: 使用模型的权限。

- `models:register`: 注册模型的权限。

- `models:unregister`: 取消注册模型的权限。

- `models:start`: 启动模型的权限。

- `models:stop`: 停止模型的权限。

- `admin`: 管理员拥有所有接口的权限。





## 配置说明

目录结构大致如下

```Plain Text
.
├── commands
│   ├── auth_config.json
│   ├── entrypoint.sh
├── docker-compose.yml
└── logs
    └── backend.log
```



### docker-compose.yml

docker compose 配置文件

样例如下

```YAML
name: docker_xinference

services:
  backend:
    image: xprobe/xinference:v0.16.1
    container_name: docker_xinference_backend
    entrypoint: [ "bash", "-c", "/home/work/commands/entrypoint.sh" ]
    restart: always
    volumes:
      - /mnt/data/ftpuser/zsftp/public/model:/home/data
      - ./commands:/home/work/commands
      - ./logs:/home/work/logs
      - /mnt/data/.xinference:/root/.xinference
      - /mnt/data/.cache/huggingface:/root/.cache/huggingface
      - /mnt/data/.cache/modelscope:/root/.cache/modelscope
    ports:
      - 19997:9997
    environment:
      - TZ=Asia/Shanghai
      # 通过魔搭下载模型 modelscope
      - XINFERENCE_MODEL_SRC=modelscope
    deploy:
      resources:
          reservations:
             devices:
             - driver: nvidia
               capabilities: [gpu]
               #device_ids: ['0','1']
               count: all
    networks:
      - docker-xinference-network

networks:
  docker-xinference-network:
    ipam:
      config:
        - subnet: 172.18.2.16/28
    driver: bridge
    name: docker-xinference-network
```



### logs

#### backend.log

xinference 控制台输出日志





### commands

#### entrypoint.sh

docker compose 中 xinference 服务的启动脚本，配置指定模型随 xinference 服务自动启动

样例如下

```Bash
#!/bin/bash

set -e -x

# ADMIN API_KEY
ADMIN_API_KEY="sk-xxxx"

# 启动 xinference 服务
xinference-local -H 0.0.0.0 --auth-config /home/work/commands/auth_config.json > /home/work/logs/backend.log 2>&1 &

# 获取上面执行的后台命令的进程 ID
command_1=$!

echo "command_1: ${command_1}"

# sleep 30

# 设置最大尝试次数
max_attempts=30
# 初始化尝试次数
attempts=0
# 重试间隔秒数
attempt_interval=5

# 循环等待，直到 curl 命令返回成功状态码或达到最大尝试次数
while [ ${attempts} -lt ${max_attempts} ]; do
    # 尝试连接服务
    http_code=$(curl --request GET 
      --url 'http://127.0.0.1:9997/' 
      -o /dev/null -w "%{http_code}") || true

    echo "curl 命令返回状态码：${http_code}"
    
    # 如果状态码为 000，则表示服务未启动
    if [ ${http_code} -eq 000 ]; then

        # 增加尝试次数
        let attempts+=1
        echo "xinference 服务未启动，状态码：${http_code}，尝试次数：${attempts}"
        # 等待一段时间再次尝试
        sleep ${attempt_interval}

    else
        echo "xinference 服务已启动，开始启动模型"
        # 服务已经启动，跳出循环
        break
    fi
done

if [ ${attempts} -ge ${max_attempts} ]; then
    echo "xinference 服务启动失败，已达到最大尝试次数 ${max_attempts}"
    exit 1
fi

# 通用模型配置
xinference launch --model-name bge-large-zh-v1.5 --model-type embedding --model-uid common-dev-bge-large-zh-v1.5 --replica 1 --gpu-idx 1 --api-key ${ADMIN_API_KEY}

xinference launch --model-name bge-reranker-large --model-type rerank --model-uid common-dev-bge-reranker-large --replica 1 --gpu-idx 1 --api-key ${ADMIN_API_KEY}

# 等待 command_1 完成，保持前台进程，避免结束当前脚本，导致 docker compsoe 重启服务
wait $command_1
```





#### auth_config.json

账号、密码、权限配置文件



- `auth_config`: 这个字段配置与安全相关的信息。

    > - `algorithm`: 用于令牌生成与解析的算法。推荐使用 `HS` 系列算法，例如 `HS256`，`HS384` 或者 `HS512` 算法。
    > 
    > - `secret_key`: 用于令牌生成和解析的密钥。可以使用该命令生成适配 `HS` 系列算法的密钥：`openssl rand -hex 32` 。
    > 
    > - `token_expire_in_minutes`: 保留字段，表示令牌失效时间。目前 Xinference 开源版本不会检查令牌过期时间。
    > 
    > 

- `user_config`: 这个字段用来配置用户和权限信息。每个用户信息由以下字段组成：

    > - `username`: 字符串，表示用户名
    > 
    > - `password`: 字符串，表示密码
    > 
    > - `permissions`: 字符串列表，表示该用户拥有的权限。权限描述如上权限部分文档所述。
    > 
    > - `api_keys`: 字符串列表，表示该用户拥有的 api-key 。用户可以通过这些 api-key ，无需登录步骤即可访问 xinference 接口。这里的 api_key 组成与 `OPENAI_API_KEY` 相似，总是以 `sk-` 开头，后跟 13 个数字、大小写字母。
    > 
    > 



生成 OPENAI_API_KEY-like 字符串代码

```Python
# -*- coding: utf-8 -*-
import random
import string

*def* generate_openai_api_key():
    prefix = "sk-"
    characters = string.ascii_letters + string.digits
    key = prefix + ''.join(random.choice(characters) for _ in range(13))
    return key

if __name__ == '__main__':
    # 使用函数生成一个 OPENAI_API_KEY-like 字符串
    openai_api_key = generate_openai_api_key()
    print(*f*'生成 OPENAI_API_KEY: {openai_api_key}')
```





auth_config.json 样例如下

```JSON
{
  "auth_config": {
    "algorithm": "HS256",
    "secret_key": "eeb9c4c368383c50ead336688aa5cd9e68287ee486f44307a84ff6208953c60e",
    "token_expire_in_minutes": 300
  },
  "user_config": [
    {
      "username": "admin",
      "password": "xxxx",
      "permissions": [
        "admin"
      ],
      "api_keys": [
        "sk-xxxx"
      ]
    }
  ]
}
```





## 日志轮转

/etc/logrotate.d/xinference.conf

```SQL
/mnt/data/xxx.log {
    rotate 5
    size 100M
    nomail
    missingok
    notifempty
    compress
    delaycompress
    create 755 user_1 user_1
}
```



# 参考文档

- [OAuth2 系统](https://inference.readthedocs.io/zh-cn/stable/user_guide/auth_system.html)
- [linux 日志轮转 logrotate 手册]({% post_url 2024/2024-11-16-linux-日志轮转-logrotate-手册 %})

