---
layout:         post
title:          通过 GitHub Pages + JeKyll 搭建自己的博客
create_time:    2019-12-27 20:44
update_time:    2022-04-16 15:02
author:         maida
categories:     [JeKyll]
tags: 
- GitHub Pages
- JeKyll
- Blog

---
### 前言
记录了自己使用通过 GitHub Pages + JeKyll 搭建博客的过程。  
以及在这个过程中碰到的困难和解决方式。  
**项目地址：**[lzc6244.github.io](https://github.com/LZC6244/lzc6244.github.io)  
**LiveDemo：**[http://lzc6244.github.io/](http://lzc6244.github.io/)

### 环境需求
- 一个属于你自己的 GitHub 帐号
- Jekyll 环境，方便本地调试（可选） [Installing Jekyll](https://jekyllrb.com/docs/installation/)  
官方建议使用 Bundler 安装和运行 Jekyll [Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/)  
但是若使用的操作系统为 Windows 笔者建议不使用 Bundler

### 步骤
- 首先我们得有一个用于搭建博客的仓库，名字为 `yourname.github.io`   
    - 可以创建[Create a new repository](https://github.com/new)  
      ![创建仓库](/imgs/JeKyll/2019/12272044_01.png)
    - 可以 fork 别人的，再自己将仓库名改为 `yourname.github.io` ，**新人推荐本方法**  
      本文以 fork [lzc6244.github.io](https://github.com/LZC6244/lzc6244.github.io) 为例
      ![fork](/imgs/JeKyll/2019/12272044_02.png)
- 将仓库下载到本地，进入仓库路径，尝试本地构建运行，浏览器输入 `127.0.0.1:4000` 查看效果
    ```bash
    cd Directory    # 进入仓库路径
    jekyll build
    jekyll serve
    ```
- 根据 fork 的项目的说明更改相应配置，将其中属于原作者的信息、参数更改为自己的
- 更改配置的过程中可以根据先在本地构建测试看一下效果，确认无误后推送到 GitHub

---

### 进阶指南
1. 自定义域名  
   - 首先，你得有一个自己的域名，笔者是在腾讯云买的（非广告）。  
     需进行域名注册、域名实名认证。由于 GitHub Pages 的服务器不在国内，所以不需要进行备案。
   - 在仓库的 `Settings` 的 `Custom domain` 处填入刚注册的域名。
   - 为域名添加指向自己博客的 DNS 解析  
       在下面 IP 中 4 选 1 ，增加 1 条 `A` 记录 （可多选，多添加）  
       下方的 IP 是 GitHub 官方提供的服务器地址
       ```text
        185.199.108.153
        185.199.109.153
        185.199.110.153
        185.199.111.153
        ```
        添加 1 条 `www` 记录，值为 `lzc6244.github.io.` ( yourname.github.io. )
   - 至此，自定义域名已配置完毕。但要注意的是，此时我们博客的链接是 `http` 的，配置 `https` 请继续阅读，该步骤可选。
     当然，我们此时可以在 GitHub 中将仓库设置为强制使用 https ，但是这个强制使用 https 使用的是 GitHub 的证书，与我们的域名不匹配。  
     若我们访问博客，浏览器地址栏将显示`不安全的证书`。
![自定义域名](/imgs/JeKyll/2019/12272044_03.png)
2. 为自定义域名启用 HTTPS  
要想配置 https ，首先我们得有属于自己的 `SSL` 证书。
以腾讯云为例，我们可以免费为自己的域名申请一个 SSL 证书。  
![申请证书01](/imgs/JeKyll/2019/12272044_04.png)  
![申请证书02](/imgs/JeKyll/2019/12272044_05.png)  
填入自己的域名、邮箱，点击下一步即可  
这里`不要设置私钥`，因为我们的博客是托管在 GitHub 上的，不是自己建站！！！  
![申请证书03](/imgs/JeKyll/2019/12272044_06.png)  
由于笔者的域名实在腾讯云购买的，所以可以直接选择`自动 DNS 验证`，可自动添加 DNS 记录验证，这里要根据自己的情况选择。
![申请证书04](/imgs/JeKyll/2019/12272044_07.png)  
**最后云解析详情如下图：**  
![云解析设置详情](/imgs/JeKyll/2019/12272044_08.png)  
**最终成果如下图：**  
![成果展示](/imgs/JeKyll/2019/12272044_09.png)

---

### 延伸阅读
1. [JeKyll 在 Windows 下本地预览中文路径](https://maida6244.xyz/2019/12/12/JeKyll-在-Windows-下本地预览中文路径.html)

### 参考
1. [GitHub Pages](https://help.github.com/cn/github/working-with-github-pages)
2. [自定义域名相关](https://help.github.com/cn/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site)
3. [creating a github pages site with jekyll](https://help.github.com/cn/github/working-with-github-pages/creating-a-github-pages-site-with-jekyll)