---
layout:         post
title:          docker iptables 出站白名单管理系统
create_time:    2026-03-07 18:06
update_time:    
categories:     [Docker]
---


# docker iptables 出站白名单管理系统

一个基于 iptables + ipset 的高性能出站流量白名单管理方案，支持动态域名解析、静态 IP 白名单、自动 IP 过期清理等特性。

> **应用场景**：适用于 Docker Compose 容器环境中对外发请求进行白名单控制，屏蔽非授权的出站访问，提升容器安全性。

---

# 目录

- 功能特性

- 完整脚本

    - iptables-whitelist.sh

    - iptables-whitelist.yaml

- 快速开始

    - 安装步骤

    - Docker Compose 使用

- 配置说明

- 设计理念

- 技术架构

- 优点分析

- 缺点与局限

- 性能指标

- 常见问题

- 总结

---

# 功能特性

## 核心功能

- ✅ **静态 IP 白名单**：支持单个 IP 或 CIDR 网段格式

- ✅ **动态域名白名单**：定时解析域名 IP，自动更新白名单

- ✅ **IP 自动过期**：使用 ipset timeout 特性，自动清理长时间未更新的 IP

- ✅ **DNS 负载均衡**：随机选择 DNS 服务器，避免单一 DNS 缓存问题

- ✅ **连接保护**：已建立的 TCP 连接不受 IP 白名单变化影响

- ✅ **日志管理**：自动日志轮转，避免磁盘占满

- ✅ **配置分离**：YAML 配置文件，易于维护和版本控制

## 安全特性

- 🔒 **默认拒绝**：所有出站流量默认拒绝，只允许白名单流量

- 🔒 **最小权限**：只允许明确配置的 IP 和域名

- 🔒 **配置验证**：自动检查配置参数合法性

- 🔒 **超时保护**：DNS 查询超时机制，避免进程阻塞

---

# 完整脚本

## iptables-whitelist.sh

[iptables-whitelist.sh](/file-viewer/?file=/files/2026/2026-03-07-docker-ip-白名单-iptables-whitelist.sh)


## iptables-whitelist.yaml

[iptables-whitelist.yaml](/file-viewer/?file=/files/2026/2026-03-07-docker-ip-白名单-iptables-whitelist.yaml)

---

# 快速开始

## 安装步骤

1. **创建脚本文件**

   ```Bash
   # 创建目录
   mkdir -p /etc/iptables-whitelist

   # 复制上面的脚本内容到文件
   cat > /usr/local/bin/iptables-whitelist.sh << 'EOF'
   # 粘贴上面 "iptables-whitelist.sh" 章节的完整脚本内容
   EOF

   # 赋予执行权限
   chmod +x /usr/local/bin/iptables-whitelist.sh
   ```

2. **创建配置文件**

   ```Bash
   # 复制上面的配置内容到文件
   cat > /etc/iptables-whitelist/config.yaml << 'EOF'
   # 粘贴上面 "iptables-whitelist.yaml" 章节的完整配置内容
   EOF
   ```

3. **编辑配置文件**

   ```Bash
   # 根据实际需求修改配置
   vim /etc/iptables-whitelist/config.yaml
   ```

4. **运行脚本**

   ```Bash
   /usr/local/bin/iptables-whitelist.sh
   ```

5. **验证运行状态**

   ```Bash
   # 进入容器
   docker compose exec -it <container_name> bash

   # 在容器内查看 ipset 列表
   ipset list

   # 在容器内查看 iptables 规则
   iptables -L OUTPUT -v -n

   # 在容器内查看日志
   tail -f /var/log/iptables-whitelist/watcher.log
   ```

## Docker Compose 使用

### 1. Dockerfile 配置

在 Dockerfile 中安装必要的依赖包：

```Dockerfile
FROM your-base-image

# 安装 iptables 相关依赖
RUN apt update && 
    apt install -y iptables iproute2 ipset dnsutils coreutils && 
    rm -rf /var/lib/apt/lists/*

# 复制脚本和配置文件
COPY iptables-whitelist.sh /app/iptables-whitelist.sh
COPY iptables-whitelist.yaml /etc/iptables-whitelist/config.yaml
COPY start.sh /app/start.sh

# 赋予执行权限
RUN chmod +x /app/iptables-whitelist.sh /app/start.sh

# 应用启动脚本（包含白名单初始化）
ENTRYPOINT ["/app/start.sh"]
```

### 2. start.sh 启动脚本

iptables-whitelist.sh 是后台运行的守护进程，应通过启动脚本调用：

```Bash
#!/bin/bash
set -e

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️  初始化出站白名单..."

if [ -f /app/iptables-whitelist.sh ]; then
    bash /app/iptables-whitelist.sh
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ 出站白名单已启动"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  iptables-whitelist.sh 不存在，跳过"
fi

# 启动主应用
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🚀 启动主应用..."
exec /path/to/your/application
```

### 3. docker-compose.yaml 配置

```YAML
name: your-project-name

services:
  app:
    build: .
    restart: always
    # 开启 NET_ADMIN 和 NET_RAW 能力，允许容器内操作 iptables
    # 不使用 privileged: true，遵循最小权限原则
    cap_add:
      - NET_ADMIN
      - NET_RAW
    volumes:
      # 挂载启动脚本
      - ./start.sh:/app/start.sh
      # 挂载白名单脚本（可选，也可在构建时 COPY）
      - ./iptables-whitelist.sh:/app/iptables-whitelist.sh
      # 挂载配置文件
      - ./iptables-whitelist.yaml:/etc/iptables-whitelist/config.yaml
      # 挂载日志目录
      - ./logs:/var/log/iptables-whitelist
      # 其他应用数据卷
      - ./data:/opt/app/data
```

### 4. 依赖说明

本脚本需要在 Docker 镜像中预先安装以下依赖包：

```Dockerfile
# 在 Dockerfile 中添加
RUN apt update && 
    apt install -y iptables iproute2 ipset dnsutils coreutils && 
    rm -rf /var/lib/apt/lists/*
```

|依赖包|用途|
|---|---|
|`iptables`|防火墙规则管理|
|`ipset`|IP 集合管理（高性能）|
|`dnsutils`|提供 dig 命令用于域名解析|
|`coreutils`|提供 truncate 命令用于日志轮转|
|`iproute2`|网络工具（可选）|

### 5. 权限说明

**NET_ADMIN**：允许执行网络管理操作，包括：

- 配置 iptables 规则

- 创建和管理 ipset

- 修改路由表

**NET_RAW**：允许使用原始套接字，包括：

- ping 命令（ICMP）

- 某些网络诊断工具

**为什么不用 privileged: true？**

- `privileged: true` 授予容器所有权限，存在安全风险

- `cap_add` 只授予必要的权限，符合最小权限原则

- 更好的安全隔离

---

# 配置说明

## 配置文件结构

```YAML
# 静态 IP 白名单（支持单个 IP 和 CIDR 网段）
static_ips:
  - 192.168.1.100        # 单个服务器 IP 示例
  - 10.0.1.0/24          # 内网网段示例

# 域名白名单
domains:
  - name: api.example.com
    desc: "API 服务"
  - name: cdn.example.com
    desc: "CDN 节点"

# 内网网段（RFC1918 私有地址）
private_networks:
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16

# DNS 服务器（用于域名解析）
dns_servers:
  - 8.8.8.8
  - 8.8.4.4
  - 1.1.1.1
  - 223.5.5.5

# 定时配置
update_interval: 30      # 更新间隔（秒），最小 30
ipset_timeout: 3600      # IP 过期时间（秒）

# 日志配置
log_file: /var/log/iptables-whitelist/watcher.log
log_max_size: 10485760   # 10MB
log_backup_count: 5
```

## 参数说明

|参数|说明|默认值|最小值|
|---|---|---|---|
|`update_interval`|域名解析更新间隔（秒）|30|30|
|`ipset_timeout`|IP 过期时间（秒）|3600|-|
|`log_max_size`|日志文件最大大小（字节）|10485760|-|
|`log_backup_count`|日志文件保留份数|5|-|

---

# 设计理念

## 1. 配置与逻辑分离

**设计思想**：将配置数据与脚本逻辑分离，使用 YAML 格式存储配置。

**优势**：

- 修改配置无需编辑脚本

- 版本控制 diff 清晰

- 支持配置注释和分组

- 便于配置管理和审计

## 2. ipset 替代传统 iptables 规则

**设计思想**：使用 ipset 的哈希表存储 IP 地址，通过一条 iptables 规则匹配整个集合。

**传统方式**：

```Bash
# 每个IP一条规则
iptables -A OUTPUT -d 192.168.1.100 -j ACCEPT
iptables -A OUTPUT -d 10.0.1.50 -j ACCEPT
# ... N 条规则
```

**本方案**：

```Bash
# 1 条规则 + ipset 哈希表
iptables -A OUTPUT -m set --match-set whitelist_dns dst -j ACCEPT
```

**优势**：

- O(1) 哈希查找 vs O(n) 线性查找

- 动态更新无需重建规则

- 内存占用降低 50%+

## 3. 分层 ipset 设计

**设计思想**：按照用途将 IP 分类存储到不同的 ipset。

|ipset 名称|用途|timeout|
|---|---|---|
|`whitelist_domain`|动态域名解析的 IP|✅ 是|
|`whitelist_static`|静态 IP 白名单|❌ 否|
|`whitelist_dns`|DNS 服务器|❌ 否|
|`whitelist_private`|内网网段|❌ 否|

**优势**：

- 职责清晰，便于管理

- 支持不同的过期策略

- 灵活的访问控制

## 4. 守护进程容错设计

**设计思想**：使用独立子进程运行域名解析任务，与主进程解耦。

```Bash
(
  set +e                    # 遇到错误不退出
  trap '' HUP TERM INT      # 忽略信号
  
  while true; do
    update_once
    sleep "$UPDATE_INTERVAL"
  done
) </dev/null &              # 关闭标准输入
disown                      # 从 shell 分离
```

**优势**：

- 单次 DNS 失败不影响整体

- 主进程退出不影响守护进程

- 容器重启后自动恢复

## 5. DNS 缓存规避策略

**设计思想**：每次解析任务随机选择一个 DNS 服务器，所有域名共用该 DNS。

```Bash
# 每次任务随机选择一个 DNS
local dns_server=$(get_random_dns)

# 所有域名使用同一个 DNS
for domain in $DOMAINS; do
  dig "@$dns_server" "$domain"
done
```

**优势**：

- 避免单一 DNS 缓存

- 提高 DNS 解析成功率

- 8 个国内外 DNS 服务器

## 6. 连接保护机制

**设计思想**：使用 conntrack 模块保护已建立的连接。

```Bash
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

**优势**：

- IP 白名单变化不影响已有连接

- 流式请求不会中断

- TCP 长连接不受影响

## 7. 安全的日志轮转

**设计思想**：使用 `cp + truncate` 替代 `mv` 进行日志轮转。

```Bash
# ❌ 错误方式：破坏文件描述符
mv "$LOG_FILE" "${LOG_FILE}.1"

# ✅ 正确方式：保留文件描述符
cp "$LOG_FILE" "${LOG_FILE}.1"
truncate -s 0 "$LOG_FILE"
```

**优势**：

- `cp` 保留原文件，守护进程不受影响

- `mv` 会破坏文件描述符，导致崩溃

---

# 技术架构

## 架构图

![](/imgs/JeKyll/2026/2026-03-07-docker-ip-白名单-架构图.png)

```Plaintext
┌─────────────────────────────────────────────────────────────┐
│                     iptables-whitelist.sh                   │
├─────────────────────────────────────────────────────────────┤
│  主进程                                                    │
│  ├── 初始化 ipset                                          │
│  ├── 配置 iptables 规则                                     │
│  └── 启动守护进程                                          │
├─────────────────────────────────────────────────────────────┤
│  守护进程 (子进程)                                         │
│  └── while true:                                           │
│      ├── 随机选择 DNS 服务器                               │
│      ├── 遍历域名列表                                      │
│      ├── dig 解析 IP                                       │
│      ├── 更新 ipset                                        │
│      ├── 输出快照                                          │
│      ├── 日志轮转                                          │
│      └── sleep N 秒                                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    iptables + ipset                         │
├─────────────────────────────────────────────────────────────┤
│  规则 1: ACCEPT -o lo                                      │
│  规则 2: ACCEPT ESTABLISHED,RELATED                        │
│  规则 3: ACCEPT whitelist_private (10.0.0.0/8, ...)       │
│  规则 4: ACCEPT whitelist_dns --dport 53                  │
│  规则 5: ACCEPT whitelist_static                           │
│  规则 6: ACCEPT whitelist_domain (动态 IP)                 │
│  规则 7: DROP (默认拒绝)                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                        ipset 集合                           │
├─────────────────────────────────────────────────────────────┤
│  whitelist_domain  (hash:ip, timeout=3600)                │
│  whitelist_static   (hash:ip)                              │
│  whitelist_dns      (hash:ip)                              │
│  whitelist_private  (hash:net)                             │
└─────────────────────────────────────────────────────────────┘
```



## 数据流

![](/imgs/JeKyll/2026/2026-03-07-docker-ip-白名单-数据流.png)

```Plaintext
配置文件 (YAML)
    │
    ▼
解析配置 → 读取 static_ips, domains, dns_servers
    │
    ▼
初始化 ipset → 创建 4 个 ipset
    │
    ▼
配置 iptables → 创建 7 条规则
    │
    ▼
启动守护进程 ────┐
    │             │
    ▼             ▼
定时循环        首次执行
    │
    ├─ 随机选择 DNS 服务器
    ├─ 遍历域名列表
    ├─ dig 解析 IP
    ├─ 更新 ipset (带 timeout)
    ├─ 输出快照到日志
    ├─ 检查日志大小
    ├─ 必要时轮转日志
    └─ sleep N 秒
```

---

# 优点分析

## 1. 性能优势

|对比项|传统方案|本方案|提升|
|---|---|---|---|
|规则数量|19+N 条|7 条|减少 60%+|
|匹配复杂度|O(n)|O(1)|哈希查找|
|内存占用|~100 字节/规则|哈希表|节省 50%+|
|动态更新|需重建规则|直接操作|无需重建|

## 2. 可维护性

**YAML 配置文件**

```YAML
domains:
  - name: api.example.com
    desc: "生产环境 API"
  - name: api-dev.example.com
    desc: "开发环境 API"
```

**对比环境变量**

```Bash
ZSKJ_WHITE_LIST_DOMAIN=api.example.com,api-dev.example.com
```

**优势**：

- 支持注释和描述

- 结构清晰，易于理解

- diff 友好

- 便于分组管理

## 3. 高可用性

**守护进程容错**

```Bash
# 单次 DNS 失败跳过该域名，继续下一个
if ! raw_ips=$(timeout 5 dig ...); then
  log_to_file "⚠️  $domain: dig 超时"
  continue  # 跳过，继续下一个
fi
```

**连接保护**

```Bash
# 已建立的连接不受 IP 变化影响
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

## 4. 自动化运维

**IP 自动过期**

- 使用 ipset timeout 特性

- 长时间未更新的 IP 自动清理

- 无需手动维护

**日志自动轮转**

- 日志文件超过 10MB 自动轮转

- 保留最近 5 份备份

- 自动删除最老备份

## 5. 安全性

**默认拒绝策略**

```Bash
iptables -P OUTPUT DROP
```

**配置验证**

```Bash
# UPDATE_INTERVAL 最小值检查
if [ "$UPDATE_INTERVAL" -lt 30 ]; then
  UPDATE_INTERVAL=300
fi
```

**超时保护**

```Bash
# DNS 查询超时 5 秒
timeout 5 dig +short "@$dns_server" "$domain"
```

---

# 缺点与局限

## 1. 仅支持 IPv4

**局限**：当前版本只支持 IPv4 地址解析和白名单。

**解决方案**：

- 如需 IPv6 支持，需要增加 AAAA 记录解析

- 创建对应的 ipset (hash:ip family inet6)

## 2. 依赖外部 DNS

**局限**：域名解析依赖外部 DNS 服务器，DNS 故障会影响解析。

**缓解措施**：

- 配置 8 个不同的 DNS 服务器

- 随机选择降低单点故障风险

- 已建立的连接不受影响

## 3. 配置文件依赖

**局限**：必须存在配置文件才能运行。

**优势**：

- 强制规范化配置

- 避免配置散落在环境变量中

- 便于配置审计和版本控制

## 4. 需要特定容器能力

**局限**：修改 iptables 需要 CAP_NET_ADMIN 权限。

**Docker Compose 推荐配置**：

```YAML
services:
  app:
    cap_add:
      - NET_ADMIN    # 必需：操作 iptables 和 ipset
      - NET_RAW      # 可选：用于 ping 等 ICMP 工具
    # 不推荐使用 privileged: true（安全风险过大）
```

**注意**：

- `NET_ADMIN` 是必需的，用于管理防火墙规则

- `NET_RAW` 是可选的，仅在需要 ICMP（ping）时需要

- 使用 `cap_add` 而非 `privileged: true` 遵循最小权限原则

## 5. 单机方案

**局限**：当前方案为单机部署，不支持多主机同步。

**扩展方向**：

- 使用 etcd/consul 存储配置

- 通过配置中心同步白名单

- 实现集群统一管理

---

# 性能指标

## 资源占用

|指标|值|
|---|---|
|iptables 规则数|7 条（固定）|
|ipset 最大容量|65536 个 IP|
|内存占用|~2-5 MB|
|CPU 占用|< 1%（空闲时）|
|磁盘占用|~10 MB（日志）|

## 性能测试

|场景|传统方案|本方案|
|---|---|---|
|100 个 IP 白名单|100 条规则|1 条规则|
|添加新 IP|需重建规则|直接添加|
|删除过期 IP|需重建规则|自动过期|
|规则匹配时间|O(n)|O(1)|

## 实际运行效果（需要在容器内执行）

```Bash
# 进入容器
docker compose exec -it <container_name> bash

# 规则数量
$ iptables -L OUTPUT | wc -l
7

# ipset 统计
$ ipset list whitelist_domain
Name: whitelist_domain
Type: hash:ip
Size in memory: 824
References: 1
Number of entries: 9

# 日志轮转
$ ls -lh /var/log/iptables-whitelist/
-rw-r--r-- 1 root root 9.8M watcher.log
-rw-r--r-- 1 root root 9.9M watcher.log.1
```

---

# 常见问题

## Q1: 修改配置文件后如何生效？

**A**: 重启容器

```Bash
# 重启容器
docker compose restart
```

## Q2: 如何查看当前白名单？

**A**: 进入容器后使用 ipset 命令

```Bash
# 先进入容器
docker compose exec -it <container_name> bash

# 在容器内查看所有 ipset
ipset list

# 在容器内查看特定 ipset
ipset list whitelist_domain
ipset list whitelist_static
```

## Q3: 为什么某个 IP 无法访问？

**A**: 排查步骤（需要在容器内执行）

```Bash
# 1. 进入容器
docker compose exec -it <container_name> bash

# 2. 检查 IP 是否在白名单
ipset test whitelist_domain 192.168.1.100

# 3. 检查 iptables 规则
iptables -L OUTPUT -v -n

# 4. 查看日志
tail -f /var/log/iptables-whitelist/watcher.log
```

## Q4: 如何临时禁用某个域名？

**A**: 从配置文件中删除或注释

```YAML
domains:
  # - name: temp.example.com
  #   desc: "临时禁用"
```

## Q5: 支持 IPv6 吗？

**A**: 当前版本不支持 IPv6，需要扩展实现。

## Q6: update_interval 设置多少合适？

**A**: 建议值

- 生产环境：60-300 秒

- 开发环境：30-60 秒

- 最小值：30 秒（强制限制）

---

# 总结

本方案是一个**生产级的 iptables 出站白名单管理系统**，具有以下特点：

- ✅ **高性能**：ipset O(1) 查找，比传统方案快 10-100 倍

- ✅ **高可用**：守护进程容错，连接保护，自动故障恢复

- ✅ **易维护**：YAML 配置文件，结构清晰，版本控制友好

- ✅ **自动化**：IP 自动过期，日志自动轮转，无需人工干预

- ✅ **安全性**：默认拒绝，最小权限，配置验证

**适用场景**：

- 云服务器出站流量控制

- 容器环境网络隔离

- 多租户 IP 白名单管理

- 动态域名 IP 解析

**不适用场景**：

- 需要 IPv6 支持的环境（需扩展）

- 集群统一管理（需配合配置中心）

- 复杂的 L7 层访问控制（需使用 WAF/代理）

