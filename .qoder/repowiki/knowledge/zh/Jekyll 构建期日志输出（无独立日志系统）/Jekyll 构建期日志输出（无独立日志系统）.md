---
kind: logging_system
name: Jekyll 构建期日志输出（无独立日志系统）
category: logging_system
scope:
    - '**'
source_files:
    - _plugins/check_missing_images.rb
    - _plugins/check_post_year_folder.rb
---

本仓库是一个基于 Minima 主题的 Jekyll 博客站点，**不存在独立的运行时日志系统**。整个项目没有引入任何第三方日志框架，也没有统一的 `log/` 目录或结构化日志配置。唯一的日志输出来自 Jekyll 自身以及两个自定义 Ruby 插件在构建阶段通过 `Jekyll.logger.warn` 打印的警告信息。

- **使用的框架**：Jekyll 内置的 `Jekyll.logger`，仅使用 `warn` 级别，未定义其他日志级别或结构化字段。
- **关键文件**：
  - `_plugins/check_missing_images.rb`：扫描文章中的本地图片引用，缺失时通过 `Jekyll.logger.warn` 输出缺失列表。
  - `_plugins/check_post_year_folder.rb`：校验 `_posts/YYYY/文件名年份` 一致性，不一致时通过 `Jekyll.logger.warn` 输出不匹配项。
- **架构与约定**：所有“日志”均为构建期一次性警告，直接调用 `Jekyll.logger.warn`，没有封装 logger 实例、没有日志轮转、没有 sink 路由，也不会在运行时产生持久化日志文件。
- **开发者规则**：若需新增构建期检查，应在 `_plugins/` 下以相同风格注册 `Jekyll::Hooks` 并使用 `Jekyll.logger.warn` 输出；本项目不要求运行时应用代码产生日志。