---
kind: dependency_management
name: Jekyll/Ruby 依赖管理（Gemfile + GitHub Pages 兼容层）
category: dependency_management
scope:
    - '**'
source_files:
    - Gemfile
    - _config.yml
    - lib/github-pages/dependencies.rb
    - lib/github-pages/plugins.rb
---

## 1. 使用的系统/方法
- 使用 Ruby 包管理器 Bundler，通过根目录 Gemfile 声明 Jekyll、主题与插件依赖。
- 针对 GitHub Pages 运行环境（Ruby 3.3.4）与本地开发环境（可能为 Ruby 4.0+）做了分支处理：
  - Ruby >= 4.0：直接显式声明 jekyll、minima、liquid 等 gem，绕过 github-pages 元包对 commonmarker 的约束。
  - Ruby < 4.0：使用 gem "github-pages", group: :jekyll_plugins 一键锁定官方兼容集。
- 站点配置 _config.yml 中通过 theme: minima 和 plugins: 列表启用第三方插件，与 Gemfile 中的 group :jekyll_plugins 对应。
- 仓库附带一份 lib/github-pages/ 子模块，复刻了 github-pages gem 的依赖版本白名单与主题映射，用于在本地或 CI 中校验/对齐 GitHub Pages 的依赖矩阵。

## 2. 关键文件与包
- Gemfile — 依赖声明入口，按 Ruby 版本分支选择安装策略，并包含 Windows 专用 wdm。
- _config.yml — 声明 theme: minima、plugins: [jekyll-sitemap, jekyll-seo-tag, jekyll-feed] 等运行时插件。
- lib/github-pages/dependencies.rb — 集中定义 GitHub Pages 官方依赖版本表（Jekyll、kramdown、liquid、rouge、各 jekyll-* 插件）。
- lib/github-pages/plugins.rb — 维护允许在 GitHub Pages 上运行的插件白名单、默认插件集合以及主题到 remote-theme 的映射。
- .bundle/ — Bundler 缓存目录（当前为空），用于存放已解析的 gem 版本信息。

## 3. 架构与约定
- 双轨依赖策略：以 RUBY_VERSION 为开关，在“直接使用 github-pages 元包”和“手动锁定核心 gem 版本”之间切换，确保本地 Ruby 4.x 也能构建成功。
- 版本来源单一事实：lib/github-pages/dependencies.rb 的 VERSIONS 常量是 GitHub Pages 官方依赖版本的权威副本；新增插件时应同步更新此处，以保持与线上环境一致。
- 插件白名单机制：plugins.rb 中的 PLUGIN_WHITELIST 与 DEFAULT_PLUGINS 定义了哪些 jekyll 插件可在 GitHub Pages 上运行，本地可额外使用 DEVELOPMENT_PLUGINS 中的工具（如 jekyll-admin）。
- 主题管理：通过 _config.yml 的 theme: minima 指定主题，同时 plugins.rb 提供主题到 pages-themes/* remote-theme 的转换映射，便于迁移。
- 平台差异处理：仅在 Windows 平台引入 wdm gem 优化文件监控，避免在其他平台上引入不必要的依赖。

## 4. 开发者应遵循的规则
- 不要绕过 Gemfile：所有 Ruby 依赖必须通过 Gemfile 声明，禁止在脚本中直接 gem install 任意版本。
- 升级前先对照 VERSIONS：修改任何 jekyll-* 插件或核心库版本前，先检查 lib/github-pages/dependencies.rb 中 GitHub Pages 是否支持该版本，必要时调整分支逻辑。
- 保持 plugins 列表一致：_config.yml 的 plugins: 列表应与 Gemfile 中 group :jekyll_plugins 下的 gem 一一对应，避免运行时找不到插件。
- 新增插件需过白名单：若要在 GitHub Pages 上运行新插件，需确认其出现在 plugins.rb 的 PLUGIN_WHITELIST 中，否则仅能在本地 DEVELOPMENT_PLUGINS 中使用。
- Windows 用户注意 wdm：在 Windows 上开发时保留 wdm 依赖，其他平台无需关心。
- 不使用私有源/锁文件：本项目未使用私有 RubyGems 源，也未提交 Gemfile.lock，依赖解析由 Bundler 在每次构建时完成。