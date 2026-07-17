---
kind: build_system
name: Jekyll 博客构建与依赖管理
category: build_system
scope:
    - '**'
source_files:
    - Gemfile
    - _config.yml
    - lib/github-pages.rb
    - lib/github-pages/configuration.rb
    - lib/github-pages/dependencies.rb
---

本仓库是一个基于 Jekyll + Minima 主题的 GitHub Pages 博客，构建系统围绕 Ruby/Gem 生态组织，核心由 Gemfile、_config.yml 以及 lib/github-pages 子模块共同驱动。

1. 使用的系统与工具
- 静态站点生成器：Jekyll（~>3.9），Markdown 引擎 kramdown，语法高亮 rouge。
- 主题：minima（~>2.5），通过 _config.yml 的 theme: minima 启用。
- 插件：jekyll-sitemap、jekyll-seo-tag、jekyll-feed（在 Gemfile 和 _config.yml 中同时声明）。
- 依赖管理：RubyGems + Bundler（Gemfile），并通过条件分支兼容本地 Ruby 4.0+ 与线上 Ruby 3.3.4 的差异。
- 部署目标：GitHub Pages（线上使用 github-pages gem 或等价依赖组合）。

2. 关键文件与包
- Gemfile：定义 jekyll/minima/kramdown-parser-gfm/webrick/csv/base64/bigdecimal 等运行时依赖；在 Ruby >= 4.0 时直接声明 jekyll 相关 gem，否则使用 github-pages 聚合 gem；Windows 下额外引入 wdm 优化文件监控。
- _config.yml：站点元信息、主题 skin/auto、permalink 格式、markdown/highlighter 设置、plugins 列表、Disqus/Google Analytics 集成等。
- lib/github-pages.rb：将 lib 加入 $LOAD_PATH 并注册 Jekyll after_reset 钩子，调用 GitHubPages::Configuration.set(site)。
- lib/github-pages/configuration.rb：实现“默认值 → 用户配置 → 覆盖”三层合并策略，强制 markdown=kramdown/gfm/commonmarkghpages，限制 highlighter=rouge，注入默认 plugins 与 whitelist，并在 development 模式下支持 DISABLE_WHITELIST 环境变量放宽白名单。
- lib/github-pages/dependencies.rb：集中锁定 jekyll、kramdown、liquid、rouge、jekyll-* 插件等版本，提供 versions/gems/version_report 查询接口，用于诊断环境一致性。

3. 架构与约定
- 双轨依赖模式：本地 Ruby 4.0+ 走显式 gem 列表（jekyll ~3.9 + minima + liquid>=4.0.4 + kramdown-parser-gfm + webrick + csv/base64/bigdecimal + jekyll-plugins 组），线上 Ruby 3.3.4 走 github-pages 聚合 gem，从而规避 commonmarker 对新版 Ruby 的限制。
- 配置合并顺序：GitHubPages::Configuration::DEFAULTS/PRODUCTION_DEFAULTS ← 用户 _config.yml ← OVERRIDES（安全/whitelist/markdown/highlighter 等）；development 下额外注入 DEVELOPMENT_PLUGINS，可通过 DISABLE_WHITELIST 关闭白名单以允许自定义插件。
- Markdown 处理器约束：仅允许 kramdown/gfm/commonmarkghpages，若设为 gfm 则自动切换为 CommonMarkGhPages 并开启 table/strikethrough/autolink/tagfilter 扩展。
- 插件加载：_config.yml 的 plugins 列表与 Gemfile group :jekyll_plugins 保持一致，确保本地与线上行为一致。
- 资源与内容结构：_posts/<year>/<date>-title.md 文章按年份分目录，assets/css|js|img 放前端资源，favicons 存放多尺寸图标与 webmanifest，files 存放随文附带的脚本/配置文件。

4. 开发者应遵循的规则
- 新增依赖：优先在 Gemfile 中声明，并确保在 Ruby < 4.0 分支也能被 github-pages 聚合包含，或在显式分支补齐；必要时同步更新 lib/github-pages/dependencies.rb 的版本号以便诊断。
- 修改构建行为：如需调整默认值或覆盖项，应在 lib/github-pages/configuration.rb 的 DEFAULTS/OVERRIDES 中操作，避免直接改 _config.yml 中的安全相关字段（如 safe、highlighter、markdown）。
- 插件开发/使用：自定义插件需放入 _plugins 目录，并在 development 下通过 DISABLE_WHITELIST=true 运行 jekyll serve 以绕过 whitelist；生产环境仍受 whitelist 限制。
- 写作规范：文章统一放在 _posts/<year>/ 下，文件名遵循 YYYY-MM-DD-title.md，配合 _config.yml 的 permalink 规则自动生成 /:year/:month/:day/:title.html 链接。
- 本地预览：推荐使用 bundle exec jekyll serve；Windows 上保持 wdm 依赖以启用增量构建。