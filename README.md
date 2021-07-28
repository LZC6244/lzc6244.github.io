### 在线预览

[https://lzc6244.github.io/](https://lzc6244.github.io/)

### 使用方法

- fork 本项目
- 修改名字为：`yourname.github.io`
- clone 到本地，参考 `_posts` 中的目录结构自己创建适合自己的文章目录结构
    - 文件名格式为：`年-月-日-文章标题` （文章标题中的空格使用 `-` 代替）（JeKyll限制）
- **必做**，修改 `_config.yml` 相关配置（耐心点看很简单，琢磨一下就OK）
- 修改 CNAME 文件中的域名为自己的域名，无自己域名将 CNAME 文件删除即可
- 本地调试（Windows）
    - 编译
        ```bash
        jekyll build
        ```
    - 运行
        ```bash
        jekyll serve
        ```
    - 浏览器打开 `http://127.0.0.1:4000/` 访问测试
    
- 允许远程访问，将运行命令更改为 `jekyll serve --host=0.0.0.0`

### JeKyll 说明
1. 基于 [suyan.github.io](https://github.com/suyan/suyan.github.io)
2. 本主题不支持使用 Markdown 创建表格，创建表格在 md 文件中使用 html 语句即可（已加入 css 优化表格展示）。[demo](https://lzc6244.github.io/2019/12/16/Xpath-轴与函数.html)