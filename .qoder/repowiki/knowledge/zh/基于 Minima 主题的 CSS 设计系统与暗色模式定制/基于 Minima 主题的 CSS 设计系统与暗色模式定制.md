---
kind: frontend_style
name: 基于 Minima 主题的 CSS 设计系统与暗色模式定制
category: frontend_style
scope:
    - '**'
source_files:
    - _config.yml
    - _includes/head.html
    - assets/css/search.css
---

本博客基于 Jekyll 官方 Minima 主题进行深度视觉定制，采用纯 CSS + CSS Variables 的设计系统实现统一风格与暗色模式支持。

## 核心架构
- 主题基座：通过 _config.yml 中 theme: minima 启用 Minima 主题，并通过 minima.skin: auto 开启自动明暗切换
- 样式覆盖策略：在 assets/css/search.css（1088行）中集中覆盖 Minima 默认样式，而非 fork 主题源码
- 字体系统：通过 Google Fonts 引入 Inter 字族，代码使用 JetBrains Mono/Fira Code 等等宽字体

## 设计令牌（Design Tokens）
所有视觉变量集中在 :root 伪类中定义，形成完整的设计令牌体系：
- 色彩系统：--color-bg / --color-text / --color-accent 等语义化变量，区分明暗两套配色
- 间距与圆角：--radius-sm/md/lg 三级圆角，配合 --shadow-sm/md 阴影层级
- 动效时长：--transition-fast/normal 统一的过渡动画时间
- 响应式断点：768px、600px、1400px 三档断点适配移动端到桌面端

## 关键样式模块
1. 全局重置：覆盖 Minima 的 h1-h6 字体粗细为 600，设置 body 基础排版
2. 吸顶导航：.site-header 使用 position: sticky + backdrop-filter: blur(8px) 毛玻璃效果
3. 搜索弹窗：全屏遮罩 + 面板滑入动画，支持关键词高亮显示
4. 文章目录侧边栏：右侧固定定位，根据标题层级缩进显示多级 TOC
5. 归档视图：原生 <details> 元素实现可折叠的年月归档列表

## 暗色模式实现
通过 @media (prefers-color-scheme: dark) 媒体查询覆盖 :root 中的 CSS 变量，无需 JavaScript 即可跟随系统主题切换。同时 _config.yml 中配置 theme-color meta 标签以匹配浏览器地址栏颜色。

## 资源组织
- 自定义样式：assets/css/search.css（唯一主样式文件）
- 交互脚本：assets/js/search.js（全文搜索逻辑）
- 图标资源：favicons/ 目录包含多尺寸 favicon 及 PWA manifest
- 字体加载：通过 Google Fonts CDN 预连接优化加载性能