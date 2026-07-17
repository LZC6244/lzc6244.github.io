---
kind: configuration_system
name: Jekyll 站点配置体系
category: configuration_system
scope:
    - '**'
source_files:
    - _config.yml
    - Gemfile
---

本仓库是一个基于 Minima 主题的 Jekyll 博客站点，其配置系统围绕 Jekyll 的约定式配置展开，核心由单一 YAML 文件与 Gemfile 共同驱动。

## 1. 使用的系统与工具
- Jekyll：静态站点生成器，通过 _config.yml 集中声明站点元信息、主题、插件、构建选项等。
- Minima 主题：通过 theme: minima 启用，并通过 minima.skin、minima.date_format 等键进行主题级配置。
- RubyGem 依赖管理：通过 Gemfile + Gemfile.lock 锁定 Jekyll 及第三方插件版本；GitHub Pages 线上使用 Ruby 3.3.4 走 github-pages gem，本地 Ruby 4.0+ 则直接声明 jekyll/minima/liquid 等依赖以绕过 commonmarker 兼容限制。

## 2. 关键配置文件
- _config.yml：站点唯一配置入口，包含 site 元数据（title、email、description、url、author）、主题与皮肤、社交链接、头像与 favicon、Disqus 短名、Google Analytics ID、permalink 规则、markdown/highlighter 引擎以及 plugins 列表。
- Gemfile：按运行环境分支声明依赖，将 jekyll-sitemap、jekyll-seo-tag、jekyll-feed 放入 group :jekyll_plugins，与 _config.yml 中的 plugins: 列表一一对应。
- .bundle/：Bundler 缓存目录，配合 GitHub Actions / CI 使用。

## 3. 架构与约定
- 单点配置：所有站点级行为集中在 _config.yml，遵循 Jekyll 默认约定（_posts/ 文章、_layouts/ 布局、_includes/ 片段、assets/ 静态资源），无需额外加载逻辑。
- 主题配置分层：通过 minima: 命名空间对 Minima 主题进行细粒度覆盖（skin、date_format），其余如 avatar、favicon、disqus、google_analytics 等作为自定义扩展键被模板或插件消费。
- 插件双源声明：_config.yml 的 plugins: 列表控制 Jekyll 启动时加载哪些插件，Gemfile 的 group :jekyll_plugins 控制 Bundler 安装范围，两者需保持一致。
- 环境差异处理：Gemfile 中根据 RUBY_VERSION 在 github-pages 与显式 jekyll/minima/liquid 之间切换，解决本地 Ruby 4.0+ 与 GitHub Pages 环境的兼容问题。

## 4. 开发者应遵循的规则
- 修改站点元信息、URL、主题皮肤、插件等，一律编辑 _config.yml，不要散落在模板或脚本中。
- 新增 Jekyll 插件时，同时更新两处：在 _config.yml 的 plugins: 列表中添加名称，并在 Gemfile 的 group :jekyll_plugins 中声明对应 gem。
- 保持 _config.yml 与 Gemfile 中插件清单一致，避免本地构建与 GitHub Pages 构建出现“插件未安装”错误。
- 如需调整 permalink、markdown 引擎或 highlighter，直接在 _config.yml 中覆盖默认值，无需改动布局或插件。
- 本地 Ruby 4.0+ 开发时依赖 Gemfile 的分支逻辑，不要手动移除 github-pages 分支代码，以免破坏 CI 一致性。