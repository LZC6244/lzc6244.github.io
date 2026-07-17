---
kind: frontend_style
name: 基于 Minima 的简约博客前端样式体系
category: frontend_style
scope:
    - '**'
source_files:
    - assets/css/search.css
    - assets/js/search.js
    - _layouts/post.html
    - _layouts/home.html
    - _config.yml
---

## 系统概述
该站点基于 Jekyll 官方 Minima 主题，通过自定义 CSS 设计令牌（Design Tokens）与少量原生 JavaScript 增强，构建出一套「黑白灰基底 + 蓝色强调色」的简约清爽风格。整体采用纯 CSS + 原生 JS 方案，无 SCSS、Tailwind 或组件库依赖。

## 核心架构
- **主题基座**：`_config.yml` 中 `theme: minima` 指定 Minima 主题，并通过 `minima.skin: auto` 启用自动明暗模式切换。
- **设计令牌集中管理**：所有颜色、圆角、阴影、字体、过渡时长均定义在 `assets/css/search.css` 顶部的 `:root` CSS 变量中，并配套 `@media (prefers-color-scheme: dark)` 提供暗色变体。
- **覆盖策略**：通过高优先级选择器（大量 `!important`）直接覆盖 Minima 默认样式，而非继承/扩展其 Sass 源。
- **交互逻辑内联**：目录侧边栏、代码块工具栏、首页视图切换等交互以 IIFE 形式嵌入 `_layouts/post.html` 和 `_layouts/home.html`，避免额外文件。

## 关键文件
- `assets/css/search.css` — 全部前端样式与设计令牌（1306 行），包含全局重置、Minima 覆盖、搜索弹窗、文章排版、归档列表等。
- `assets/js/search.js` — 全文搜索索引加载、全屏弹窗、分页滚动、字符计数等交互。
- `_layouts/post.html` — 文章布局，内嵌目录生成与代码块工具栏脚本。
- `_layouts/home.html` — 首页布局，内嵌分类/日期视图切换脚本。
- `_config.yml` — 主题与插件配置入口。

## 视觉规范
- **色彩**：亮色背景 `#fafbfc` / 卡片 `#ffffff` / 强调蓝 `#3b82f6`；暗色背景 `#0f1117` / 卡片 `#1a1d27` / 强调蓝 `#60a5fa`。
- **字体**：正文使用 Inter 系统字体栈，代码使用 JetBrains Mono 等等宽字体。
- **圆角**：统一 6px / 10px / 14px 三级。
- **阴影**：仅两级浅阴影，保持极简。
- **语义化提示框**：通过 `<blockquote class="info|tip|warning|danger">` 实现四级提醒，带 emoji 前缀与对应配色。
- **行内代码语义类**：`code.cmd` / `code.path` / `code.flag` / `code.val` / `code.key` 区分命令、路径、参数、值、按键。

## 响应式策略
- 使用 `clamp()` 控制标题字号随视口缩放。
- 搜索框在小屏（≤600px）隐藏，弹窗在全屏模式下适配移动端。
- 目录侧边栏在 ≤1200px 时点击链接后自动收起。

## 开发者约定
1. 新增颜色/尺寸一律修改 `:root` 中的 CSS 变量，禁止硬编码。
2. 覆盖 Minima 样式时使用 `!important` 确保优先级，但仅在必要时使用。
3. 交互脚本以 IIFE 包裹并自执行，避免污染全局命名空间。
4. 代码块语言标签由 post 模板自动提取 `language-xxx` 类名显示，无需手动标注。
5. 图片统一居中并加圆角边框，遵循 `.post-content img` 规则。