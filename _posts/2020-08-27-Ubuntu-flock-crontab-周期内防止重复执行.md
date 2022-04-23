---
layout:         post
title:          Ubuntu flock crontab 周期内防止重复执行
create_time:    2020-08-27 19:56
author:         maida
categories:     [Ubuntu]
tags:
 - Ubuntu
 - crontab
 - flock
 - linux单实例
---

### 前言
使用定时任务 `crontab` 时防止周期内重复执行任务。  

如：定时任务 **test** 执行需要耗费时间 2 分钟，但是 crontab 中配置 1 分钟执行 1 次。  

使用 `flock` 可为其加锁，避免多实例（windows 中**计划任务**可以直接设置不启动新实例）

### 使用示例
crontab 中 
原（以每分钟启动为例）
```text
*/1 * * * * python test.py
```

更改为
```text
*/1 * * * * flock -xn test.lock -c "python test.py"
```

### flock 参数简单介绍
```text
-s, --shared     共享锁 
-x, --exclusive  独占锁 
-u, --unlock     移除一个锁，脚本执行完会自动丢弃锁 
-n, --nonblock   如果没有立即获得锁，直接失败而不是等待 
-w, --timeout    如果没有立即获得锁，等待指定时间 
-o, --close      在运行命令前关闭文件的描述符号。用于如果命令产生子进程时会不受锁的管控 
-c, --command    在shell中运行一个单独的命令 
```
更多信息请使用 `flock --help` 查看

### 已经做过的一些简单测试
- 运行实例时删除 '*.lock' 文件，程序执行不受影响
- 运行实例时 'kill -9 进程号' ,显示 'killed' 但是程序测试打印仍在继续即未真正杀掉该实例进程