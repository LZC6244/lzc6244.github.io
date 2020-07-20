---
layout:     post
title:      Redis and MongoDB 设置密码验证(scrapy)(win)(ubuntu)
date:       2020-02-01 11:01
author:     maida
categories: [Ubuntu]
tags:
 - Ubuntu
 - Redis
 - MongoDB
 - authentication
---

### 1 . Redis
- win10  
  ```text
    1.找到 redis.windows.conf ,对其进行编辑。将 
    # requirepass foobared
    更改为
    requirepass yourpassword
    2.重新启动 redis-server 服务,如: redis-server redis.windows.conf 
    (以redis.windows.conf为配置启动redis-server)
    ```  
  ![修改requirepass-win10](/imgs/JeKyll/2020/02011101_01.png)
- ubuntu
  ```text
    1.ubuntu下Redis的配置文件为 redis.conf ,找到,如上win10处更改
    2.重新启动 redis-server 使配置生效： sudo systemctl restart redis-server
    ps:查找 redis.conf 可以按序用以下命令：
    sudo updatedb
    locate redis.conf
    ```  
  ![查找redis.conf-ubuntu](/imgs/JeKyll/2020/02011101_02.png)  
  ![修改requirepass-ubuntu](/imgs/JeKyll/2020/02011101_03.png)
- scrapy
  ```text
    1.在 settings.py 中添加如下字段：
    REDIS_HOST = 'x.x.x.x'        ( redis-server ip )
    REDIS_PORT = 6379             ( redis-server port )
    REDIS_PARAMS = {'password': 'yourpassword'}    ( redis-server password )
    
    2. 拓展 -- 在 scrapy 的其他文件使用，如 spider
    import redis
    from FDASpider.settings import REDIS_HOST, REDIS_PORT, REDIS_PARAMS
    
    pool = redis.ConnectionPool(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PARAMS['password'])
    r = redis.Redis(connection_pool=pool)
    ```
  
### 2. MongoDB
- win10
  ```text
    1.首先保证 MongoDB 服务是开启的
    2.在 cmd 输入命令：mongo 登陆 MongoDB
    3.在 MongoDB 下输入以下命令：
    use admin    ( 切换到 admin 数据库 )
    db.createUser({user:"name",pwd:"yourpassword",roles:[{role:"root",db:"admin"}]})    （ 创建拥有 root 权限的跨库用户 ）
    db.auth('name','yourpassword')    （ 验证是否登录成功，返回1则成功 ）
    4.重启 MongoDB ,带上参数 -auth ,如:
    mongod -dbpath D:\mongodb\data\ -logpath yourlogpath\mongodb_log.log -logappend -auth
    ```
- ubuntu
    ```text
    1.保证 MongoDB 服务开启
    2.如 win10 处操作创建用户
    3.修改 MongoDB 配置文件: sudo vim /etc/mongod.conf
    将 #securit 去掉注释，添加 'authorization: enabled'
    4.重启 MongoDB 服务: service mongodb restart
    ```  
  ![创建管理员-ubuntu](/imgs/JeKyll/2020/02011101_04.png)  
  ![启用验证-ubuntu](/imgs/JeKyll/2020/02011101_05.png)
- scrapy
    ```text
    1.在 settings.py 中添加如下字段：
    MONGO_URI = 'mongodb://127.0.0.1:27017'
    MONGO_DB = "databasename"
    2.其他都简单，重点是连接数据库的时候的验证语句，要加上 source ：
    db.authenticate(name='name', password='yourpassword', source='admin')
    ```