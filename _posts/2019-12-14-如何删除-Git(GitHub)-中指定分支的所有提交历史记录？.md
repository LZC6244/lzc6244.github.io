---
layout:         post
title:          如何删除 Git/GitHub 中指定分支的所有提交历史记录？
create_time:    2019-12-14 14:29
author:         maida
categories:     [Git]
tags:
 - Git
 - VCS
---

## 描述

在使用 `Git/GitHub` 的过程中，我们总会因为这样那样的原因想要删除某（些）次提交历史记录。  
譬如，好不容易调好了程序可以运行，最后发现，WTF 竟然把自己的帐号密码啊ID啊什么的  
**也一并提交上去了！！！**  

这可咋整啊   ⊙︿⊙  
总不能把这个仓库删了？然后重新创？  
。。。。。。。 

Git 肯定是能做到删除指定次提交的  
但一方面笔者研究之后发现删除上一次的提交还好，要是删除上N次的，那就复杂了  
另一方面笔者也没有实际上进行过这种操作，故不在本文介绍。  

由于笔者的 GitHub 都是只有自己操作  (⊙ ▽ ⊙)  
（不会干掉了别人的 commit 挨捶）  
况且笔者也只是觉得仓库 commit 太多次了，有许多不足之处，并且当前 commit 才算是初步完成项目 (⊙ω⊙)  
才打算删除 commit 记录的  

**废话不多说，开整！**

## 步骤
删除指定分支的所有提交历史记录。  
- 检出当前仓库最新版本作为新分支 `git checkout --orphan latest_branch`
- 添加所有文件 `git add -A`
- 提交更改 `git commit -am "initial commit"` （在这里无耻的写上了 "initial commit" 假装是第一次提交，哈哈。这里提交消息可以自己随便写。）
- 删除分支 `git branch -D master` ，master 是分支名
- 将当前分支 **latest_branch** 重命名为 **master** ，`git branch -m master`
- 强制更新到远程仓库 `git push -f origin master`
