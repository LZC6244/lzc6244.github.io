---
kind: design
name: GitHub Actions 自建构建部署决策（弃用 Pages 默认分支构建）
source: user
category: adr
---

## 结论
站点构建部署从 GitHub Pages 默认分支构建切换为自有 GitHub Actions 流水线（.github/workflows/pages.yml，Ruby 4.0 + JEKYLL_ENV=production + bundler-cache），前置条件是仓库 Pages Source 设为 "GitHub Actions"，触发源为 master 分支 push 与 workflow_dispatch。

## 理由与权衡
- 根本动因：Pages 默认构建只允许白名单 gem 插件，完全不执行 _plugins/ 下的自定义插件，导致线上与本地渲染不一致（典型例子：代码块中的 {{ }} 如 docker --format "{{.Name}}" 被 Liquid 解析成空字符串，依赖 escape_code_liquid.rb 修复）。
- Ruby 版本选 4.0 而非 3.x：让 Gemfile 走显式依赖分支，与本地环境一致；若用 3.x 会落入 github-pages 聚合 gem 分支，该 gem 强制 safe 模式与插件白名单，_plugins/ 又会被禁用。
- 代价：需自行维护 workflow 与依赖缓存，失去 Pages 官方构建的托管便利；通过 bundler-cache 缓存 gem 依赖缓解构建耗时。

## 已否决的备选方案
- 继续 Pages 默认分支构建：无法启用 _plugins/，放弃。
- Actions 中用 Ruby 3.x + github-pages 聚合 gem：safe 模式仍禁用自定义插件，放弃。
- 本地预构建后提交 _site 产物：污染仓库且易遗漏，放弃。

## 适用条件与失效边界
- 适用于依赖 _plugins/ 自定义插件且要求线上与本地渲染一致的场景；若未来移除全部自定义插件且依赖均在 Pages 白名单内，可回退默认分支构建（但需同步移除 workflow 并将 Pages Source 切回 branch）。
- Pages Source 若被误切回 "Deploy from a branch"，workflow 不会接管部署，需作为部署故障的首选排查项。