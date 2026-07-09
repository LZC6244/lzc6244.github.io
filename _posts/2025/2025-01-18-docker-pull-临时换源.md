---
layout:         post
title:          docker pull 临时换源
create_time:    2025-01-18 19:16
update_time:    
categories:     [Docker]
---


# docker 镜像换源查询



渡渡鸟：https://docker.aityp.com/





## 使用

- 在上面的站点查询镜像名称，进到镜像详情页查看该镜像对应国内镜像地址进行换源拉去镜像



# 换源命令

```Bash
# 终端中临时换源，换源替换【hub.uuuadc.top】这部分即可
docker pull hub.uuuadc.top/library/node:20-slim

# 可选
# 查看镜像信息（如 id ）
docker images
# 将换源镜像重命名为官方镜像名称（两个镜像实际指向同一份本地文件，通过镜像 id 就可以看出来）
docker tag hub.uuuadc.top/library/node:20-slim node:20-slim
# 查看镜像信息（如 id ）
docker images
# 删除换源镜像（相当于删除软链接）
docker rmi hub.uuuadc.top/library/node:20-slim

```



## 注意

library 是一个特殊的命名空间，它代表的是官方镜像

如果是某个用户的镜像就把 library 替换为镜像的用户名





20240606 后开始陆续有国内源不可用





![image.png](/imgs/JeKyll/2025/2025-01-18-docker-pull-临时换源-001.png)



# 镜像源参考

<br>

## GitHub

- https://github.com/gebangfeng/docker-mirror?tab=readme-ov-file：dhub.kubesre.xyz

- https://github.com/DaoCloud/public-image-mirror



# 参考文档

- https://docs.docker.com/trusted-content/official-images/using/

- https://docs.docker.com/reference/cli/docker/image/pull/?highlight=pull

