---
layout:         post
title:          docker compose 网络数达到上限解决方案
create_time:    2026-03-01 17:03
update_time:    
categories:     [Docker]
---


# 方案

以下为不需要重启 docker 增加网络数上限方案：指定新的子网

参考样例：

```YAML
# 默认可用内网网段：172.16.0.0/12 ; 192.168.0.0/16
# 下面是几个划分小网段的示例，不用过度分配网段避免资源浪费


# 可用主机地址：172.17.0.1 ～ 172.17.0.14
# default 表示随着 docker compose 项目名称自动命名 docker 网络名称
networks:
  default:
    ipam:
      config:
        - subnet: 172.17.0.0/28 


# or        


# 可用主机地址：172.17.0.17 ～ 172.17.0.30        
networks:
  target-network:
    ipam:
      config:
        - subnet: 172.17.0.16/28
```

<br>

<blockquote class="info">
优化：子网可以指定如【172.17.0.0/28】和【172.17.0.16/28】等小范围子网，合理安排资源
</blockquote>







# 参考文档
- [docker 查看已有网络的内网 ip]({% post_url 2025/2025-02-22-docker-查看已有网络的内网-ip %})
- https://docs.docker.com/compose/compose-file/06-networks/#ipam



