---
kind: configuration_system
name: Jekyll 站点配置（_config.yml + Gemfile）
category: configuration_system
scope:
    - '**'
source_files:
    - _config.yml
    - Gemfile
    - _includes/head.html
---

本仓库为基于 Jekyll + Minima 主题的个人博客，配置系统完全遵循 Jekyll 官方约定，采用单一 YAML 配置文件集中管理站点元数据、主题行为与构建选项。

## 使用的系统与工具
- **Jekyll 3.9**：静态站点生成器核心，负责读取 `_config.yml`、渲染 Liquid 模板、处理 Markdown/代码高亮等。
- **Minima 2.5**：官方默认主题，通过 `minima.skin` 和 `minima.date_format` 等命名空间键进行定制。
- **Liquid 4+**：模板引擎，支持 `jekyll.environment` 等内置变量用于条件渲染。
- **Kramdown + Rouge**：Markdown 解析器与语法高亮后端。
- **Gemfile**：声明 Jekyll 及其插件依赖，配合 GitHub Pages 的 Ruby 环境使用。

## 关键文件与位置
- `_config.yml`：站点全局配置入口，包含站点信息、主题参数、社交链接、评论与分析、URL 规则、插件列表等。
- `Gemfile` / `Gemfile.lock`：Ruby 依赖锁定，确保本地与 GitHub Pages 构建一致。
- `_includes/head.html`：引用 `jekyll.environment` 环境变量控制 Google Analytics 注入。
- `.gitignore`：忽略 `.env`、`local_settings.py` 等敏感/本地配置（来自通用模板）。

## 架构与约定
1. **单文件集中配置**：所有站点级设置集中在 `_config.yml`，按语义分组注释（Site settings / Theme / Social links / Build settings / Plugins），无多环境拆分。
2. **主题配置通过命名空间**：Minima 主题相关键以 `minima:` 前缀组织，避免与 Jekyll 内置键冲突。
3. **插件双清单**：`_config.yml` 的 `plugins:` 列表与 `Gemfile` 的 `group :jekyll_plugins` 同步声明同一组插件（sitemap、seo-tag、feed），保证加载一致性。
4. **环境变量驱动的条件渲染**：通过 `jekyll.environment == 'production'` 在模板中判断是否注入分析脚本，实现开发/生产差异化。
5. **内容 URL 规范**：`permalink: /:year/:month/:day/:title.html` 统一文章永久链接格式，与 `_posts/年份/日期-标题.md` 目录结构对应。

## 开发者应遵循的规则
- 新增站点元数据或主题开关时，优先在 `_config.yml` 对应注释区块下添加，保持分组清晰。
- 修改 Minima 主题行为一律使用 `minima.*` 命名空间键，不要直接覆盖主题内部变量。
- 需要区分开发与生产环境的逻辑，应在 Liquid 模板中使用 `jekyll.environment` 判断，而非硬编码。
- 新增 Jekyll 插件时，同时更新 `_config.yml` 的 `plugins:` 列表与 `Gemfile` 的 `jekyll_plugins` 分组，并运行 `bundle install` 锁定版本。
- 敏感信息（如 API Key）不应写入 `_config.yml`；本仓库未启用外部 secrets 管理，如需扩展可考虑 GitHub Actions Secrets + Liquid 注入，但当前项目无需此机制。