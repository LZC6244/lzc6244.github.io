---
kind: build_system
name: Jekyll + Minima 静态站点构建体系
category: build_system
scope:
    - '**'
source_files:
    - Gemfile
    - Gemfile.lock
    - _config.yml
---

本项目是一个基于 Jekyll 3.9 与 Minima 2.5 主题的个人博客，采用典型的 Jekyll 静态站点生成模式，无自定义 Makefile、Dockerfile 或 CI 流水线。构建完全由 Jekyll CLI 驱动，通过 Ruby Gem 管理依赖，GitHub Pages 托管并自动触发构建。

**核心构建配置**
- `Gemfile`：声明 Jekyll 3.9、Minima 2.5 及 Liquid、Webrick、CSV、Base64、BigDecimal 等 Ruby 3.4+ 兼容补丁；在 `jekyll_plugins` 组中引入 `jekyll-sitemap`、`jekyll-seo-tag`、`jekyll-feed` 三个官方插件。
- `_config.yml`：站点元信息、Minima skin（auto）、permalink 格式（`:year/:month/:day/:title.html`）、Markdown 解析器 kramdown、代码高亮 rouge、Disqus 与 Google Analytics 集成。
- `Gemfile.lock`：锁定所有依赖版本，确保本地与 GitHub Pages 构建一致性。

**构建产物与目录约定**
- `_posts/` 下按 `YYYY-MM-DD-title.md` 命名规范存放文章，Jekyll 自动解析 front matter 并按 permalink 规则生成 HTML。
- `_includes/`、`_layouts/`、`_plugins/` 分别承载可复用片段、页面布局与自定义 Ruby 插件（如 `ruby34_compat.rb`、`year_category_filter.rb`）。
- `assets/` 存放 CSS/JS/图片资源，`favicons/` 提供多尺寸 favicon 与 webmanifest。
- `_site/` 为 Jekyll 生成的静态输出目录，由 `.gitignore` 排除提交。

**发布流程**
- 本地开发：`bundle exec jekyll serve` 启动预览服务器。
- 生产构建：GitHub Pages 检测到推送后，基于 `Gemfile.lock` 中的固定版本执行 `jekyll build`，将 `_site/` 部署到 `https://lzc6244.github.io/`。
- 无自定义 CI/CD 脚本，完全依赖 GitHub Pages 内置的 Jekyll 构建能力。

**开发者约束**
- 新增文章必须遵循 `_posts/YYYY/MM-DD-标题.md` 命名约定。
- 依赖变更需更新 `Gemfile` 并通过 `bundle install` 同步 `Gemfile.lock`，否则 GitHub Pages 构建可能因版本漂移失败。
- 自定义功能优先以 `_plugins/` 下的 Ruby 插件或 `_includes/_layouts` 覆盖方式实现，避免修改 Minima 源码。