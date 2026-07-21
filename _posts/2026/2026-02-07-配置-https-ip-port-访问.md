---
layout:         post
title:          配置 https://ip:port 访问
create_time:    2025-02-07 20:01
update_time:    
categories:     [Other]
---


# 需求

为 `http://ip:port` 服务配置 https 方式访问：`https://ip:port`



注：可在 nginx 层面将 http 流量转到 https





# 方案



本文选择【方案一：使用自签名 https 证书 + 手动信任】

【方案二：使用内网域名 + 自建私有 CA】<span style="color:orange">需要客户端手动安装证书来信任</span>

根据实际场景选择方案即可，本文不赘述





## 方案一：使用自签名 https 证书 + 手动信任



1. 生成 https 证书

   ```bash
   # 生成私钥
   openssl genrsa -out server.key 2048

   # 生成证书（CN 填部署服务器的 IP 地址）
   openssl req -new -x509 -key server.key -out server.crt -days 365 -subj "/CN=192.168.1.100"
   ```

2. nginx 配置

   ```Nginx
   server {
       listen 443 ssl;
       server_name 192.168.1.100;  # 或你的公网 IP

       ssl_certificate /path/to/server.crt;
       ssl_certificate_key /path/to/server.key;

       location / {
           proxy_pass http://127.0.0.1:8080;  # 转发到你的后端 HTTP 服务
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. 重新加载 nginx 配置：`nginx -s reload`

4. （可选）HTTP 自动跳转到 HTTPS，新增 server 块

   ```Nginx
   server {
       listen 80;
       server_name 192.168.1.100;
       return 301 https://192.168.1.100$request_uri;
   }
   ```



## 方案二：使用内网域名 + 自建私有 CA



步骤：

1. 搭建一个私有 CA（如用 mkcert 或 Smallstep）

2. 用该 CA 为内网服务（如 myapp.local）签发证书

3. 将私有 CA 的根证书安装到所有客户端（开发机、手机等）



客户端/浏览器将不再提示不安全的证书



