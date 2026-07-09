---
layout:         post
title:          dozzle - web 可视化 docker 日志
create_time:    2026-01-24 10:05
update_time:    
categories:     [Docker]
---



# 介绍

Dozzle 是由 Docker OSS 赞助的开源项目。它是一个日志查看器，旨在简化容器的监控和调试。这个轻量级的、基于 Web 的应用程序通过直观的用户界面提供实时日志流、过滤和搜索功能。



开源地址：https://github.com/amir20/dozzle



# 部署



## 证书管理

公网暴露 dozzle agent 节点建议更改默认证书

不然别人指定明确的 agent ip 和 端口能够访问到该 agent 节点信息



官方证书生成命令

```TOML
openssl genpkey -algorithm Ed25519 -out key.pem
openssl req -new -key key.pem -out request.csr -subj "/C=US/ST=California/L=San Francisco/O=My Company"
openssl x509 -req -in request.csr -signkey key.pem -out cert.pem -days 365
```

参考文档：https://dozzle.dev/guide/agent



## docker compose

<br>

### 独立 docker 模式

参考文档：https://dozzle.dev/guide/getting-started



### agent 代理模式



通过 agent 代理模式可以方便查看其他机器节点的 docker 日志



先启动 agent 节点再启动 master ui 节点



```YAML
name: dozzle-master

services:
  dozzle:
    image: amir20/dozzle:latest
    restart: always
    environment:
      DOZZLE_REMOTE_AGENT: agent节点ip1:7007,agent节点ip2:7007
      DOZZLE_AUTH_PROVIDER: simple
      DOZZLE_CERT: /certs/cert.pem
      DOZZLE_KEY: /certs/key.pem
    volumes:
      - ./users-master.yml:/data/users.yml
      - ./certs:/certs
    ports:
      - 8006:8080 # Dozzle UI port

networks:
  default:
    ipam:
      config:
        - subnet: 172.18.100.0/28
```



```YAML
name: dozzle-agent

services:
  dozzle:
    image: amir20/dozzle:latest
    command: agent
    restart: always
    healthcheck:
      test: ["CMD", "/dozzle", "healthcheck"]
      interval: 5s
      retries: 5
      start_period: 5s
      start_interval: 5s
    environment:
      DOZZLE_HOSTNAME: 自定义机器显示名称
      DOZZLE_CERT: /certs/cert.pem
      DOZZLE_KEY: /certs/key.pem
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./config/certs:/certs
    ports:
      - 7007:7007

networks:
  default:
    ipam:
      config:
        - subnet: 172.18.100.16/28
```



# 用户配置文件样例



users-master.yml 样例如下

```YAML
# 无需重启，直接往下面加用户就行
# 无需重启，更新用户重新登录即可生效

users:
    admin:
        email: ""
        name: 管理员
        password: xxxxxxxxxxxxxxxxxxxxxxxx
        filter: ""
        roles: ""

    guest:
        email: ""
        name: 访客
        password: xxxxxxxxxxxxxxxxxxxxxxxxxxx
        filter: "name=k8s_*"
        roles: download
```







# 账号管理



添加用户无需重启 master 服务

用户权限更新，该用户重新登录即可生效

用户验证参考文档：https://dozzle.dev/guide/authentication#setting-specific-roles-for-users



1. 在项目路径下执行下面生成密码命令

   ```text
   docker run -it --rm 
     -v key.pem:/certs/key.pem 
     -v cert.pem:/certs/cert.pem 
     amir20/dozzle:v8.14.9 
     generate --name 用户显示名称 
     --password 密码 
     --user-roles download 
     账号英文名称
   ```

   上面的命令挂载 key.pem 和 cert.pem 指定了自定义证书

2. 将生成的账号密码加入当前项目的 `compose/config/users-master.yml` 文件中

   ![](/imgs/JeKyll/2026/2026-01-24-dozzle-web-可视化-docker-日志-001.png)

3. 根据实际情况配置用户对 docker 容器的可见权限

   如：配置用户只能访问 sqlbot_* 的 docker 容器

   ```TOML
   filter: "name=k8s_*"
   ```

配置多个则类似如下

```TOML
filter: "name=k8s_*,name=name2,name=name3"
```

![](/imgs/JeKyll/2026/2026-01-24-dozzle-web-可视化-docker-日志-002.png)





# 参考

1. [过滤容器](https://dozzle.dev/guide/filters)

