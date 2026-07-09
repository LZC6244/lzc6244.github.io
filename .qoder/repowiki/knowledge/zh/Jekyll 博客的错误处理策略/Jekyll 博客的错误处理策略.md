---
kind: error_handling
name: Jekyll 博客的错误处理策略
category: error_handling
scope:
    - '**'
source_files:
    - 404.html
    - ie.html
    - assets/js/search.js
    - _plugins/ruby34_compat.rb
    - _plugins/year_category_filter.rb
---

该仓库是一个基于 Jekyll + Minima 主题的静态博客站点，整体错误处理非常轻量且遵循静态站点的常见模式：

1. **HTTP 404 页面**：根目录提供 `404.html`，使用默认布局渲染一个友好的“页面不存在”提示。
2. **浏览器兼容性降级**：`ie.html` 作为 IE 等旧浏览器的兼容页面，直接返回纯 HTML，提示用户升级浏览器或扫码移动端访问。
3. **前端搜索索引加载失败**：`assets/js/search.js` 在通过 `fetch` 加载 `search.json` 时，对 `.catch()` 分支统一插入 `<div class="search-error">无法加载搜索索引</div>` 并打开搜索弹窗，属于静默降级——不影响主站功能。
4. **Ruby/Jekyll 插件**：两个 `_plugins/*.rb` 文件（`ruby34_compat.rb`、`year_category_filter.rb`）均为功能性扩展，未定义自定义异常类型或显式错误传播逻辑；依赖 Jekyll/Liquid 自身的构建期错误机制。
5. **无全局中间件/panic/recover**：作为静态站点生成项目，没有服务端中间件层，也不使用 Ruby 的 `raise/rescue` 或 JS 的 `try/catch` 进行结构化错误传播。

总结：该仓库的错误处理以“友好页面 + 静默降级”为主，不追求细粒度的错误分类与上报，符合个人博客类静态项目的定位。