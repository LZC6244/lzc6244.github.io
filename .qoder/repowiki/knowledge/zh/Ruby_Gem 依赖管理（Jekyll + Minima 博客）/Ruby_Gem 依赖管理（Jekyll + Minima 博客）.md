---
kind: dependency_management
name: Ruby/Gem 依赖管理（Jekyll + Minima 博客）
category: dependency_management
scope:
    - '**'
source_files:
    - Gemfile
    - Gemfile.lock
    - _config.yml
    - .gitignore
---

## 依赖管理系统概述

该 Jekyll 个人博客站点使用 Ruby 生态系统的 Gem 包管理器进行依赖管理，基于 Bundler 工具链实现可重复构建。

## 核心配置文件

**Gemfile** - 主要依赖声明文件：
- 核心框架：`jekyll (~> 3.9)`、`minima (~> 2.5)` 主题
- Ruby 3.4+ 兼容性修复：显式声明 `liquid (>= 4.0.4)`、`webrick`、`csv`、`base64`、`bigdecimal`
- Markdown 支持：`kramdown-parser-gfm` 用于 GitHub Flavored Markdown
- 插件组：通过 `group :jekyll_plugins` 管理 `jekyll-sitemap`、`jekyll-seo-tag`、`jekyll-feed`

**Gemfile.lock** - 锁定所有依赖的精确版本，确保构建一致性，包含完整的依赖树和 SHA256 校验和。

**_config.yml** - Jekyll 配置中声明运行时插件列表，与 Gemfile 中的 jekyll_plugins 组对应。

## 版本策略与约束

- 主框架使用波浪号约束符（`~>`），允许小版本更新但限制大版本升级
- 针对 Ruby 3.4+ 兼容性问题的 gem 使用宽松约束（`>=`）
- 平台特定依赖如 `ffi (1.17.4-x64-mingw-ucrt)` 针对 Windows 环境

## 构建与部署

- 使用 Bundler 4.0.15 管理依赖安装
- 目标平台为 `x64-mingw-ucrt`（Windows 环境）
- `_site/`、`.jekyll-cache/`、`vendor/` 等构建产物被 `.gitignore` 排除

## 开发约定

- 所有 Ruby gem 依赖必须在 Gemfile 中显式声明
- 依赖变更需提交对应的 Gemfile.lock 更新
- 插件依赖通过 Bundler group 机制组织，保持清晰的职责分离