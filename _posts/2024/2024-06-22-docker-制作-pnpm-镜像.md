---
layout:         post
title:          docker 制作 pnpm 镜像
create_time:    2024-06-22 19:35
update_time:    
categories:     [Docker]
---


# 背景

目前未发现、未提供官方 pnpm docker 镜像，所以就只能自力更生咯。



# Dockerfile

```Dockerfile
FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
# 指定要安装的 pnpm 版本
ENV PNPM_VERSION=9.0.5
# 更换华为源并安装指定版本 pnpm
RUN npm config set registry https://mirrors.huaweicloud.com/repository/npm/ && 
    npm install -g pnpm@${PNPM_VERSION}
```





# 参考文档

- https://pnpm.io/zh/docker

- [npm 安装 pnpm](https://pnpm.io/zh/installation#%E4%BD%BF%E7%94%A8-npm-%E5%AE%89%E8%A3%85)

