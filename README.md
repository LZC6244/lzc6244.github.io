### 在线预览

[https://lzc6244.github.io/](https://lzc6244.github.io/)

### 简介

基于 GitHub Pages + Jekyll 搭建的个人博客，主题基于官方 Minima 并深度定制为**简约清爽**风格。

特性：
- **简约清爽主题** — 黑白灰基底 + 蓝色强调色，大量留白，柔和圆角
- **Inter 字体** — 现代无衬线字体，clamp() 响应式字号，清晰易读
- **CSS 变量设计体系** — 统一的设计令牌，亮色/暗色模式自动切换
- **全文搜索** — 搜索文章标题和正文内容，弹窗式结果展示，分页加载
- **分类/日期双视图** — 首页切换分类归档与时间线视图，分类按首字母排序、默认折叠
- **文章目录（TOC）** — 侧边栏目录，兼容 h1~h6 全层级标题，滚动高亮当前章节
- **代码块折叠** — 超过 20 行的代码块自动折叠，保持页面整洁
- **行内代码语义样式** — `.cmd` `.path` `.flag` `.val` `.key` 等语义化类名
- **分级提示框** — `.info` `.tip` `.warning` `.danger` 四级提醒，兼容 GitHub 原生告警语法
- **附件在线预览** — `files/` 目录下的脚本、配置等文本文件可在浏览器中直接预览
- **Disqus 评论** — 文章底部自动加载评论区
- **Google Analytics** — 生产环境自动注入统计脚本
- **Favicons** — 完整的 favicon 图标集，支持各平台
- **响应式布局** — 移动端适配，支持暗色模式
- **自定义插件** — Liquid 语法自动转义、目录分类过滤、Ruby 3.4+ 兼容等

### 项目结构

```
lzc6244.github.io/
├── _config.yml          # 站点配置（标题、社交链接、Disqus、GA 等）
├── Gemfile              # Ruby 依赖声明
├── _includes/           # 可复用模板片段
│   ├── head.html        #   <head> 标签（字体、CSS、favicon、GA）
│   ├── header.html      #   顶部导航栏 + 搜索框
│   └── footer.html      #   页脚 + 搜索弹窗容器
├── _layouts/            # 页面布局
│   ├── home.html        #   首页（分类/日期双视图）
│   └── post.html        #   文章页（元信息、正文、Disqus、TOC 侧边栏）
├── _plugins/            # Jekyll 自定义插件
│   ├── escape_code_liquid.rb    # 代码块中 {{ }} 自动转义
│   ├── year_category_filter.rb  # 过滤 _posts 子目录自动注入的分类
│   └── ruby34_compat.rb         # Ruby 3.4+ 兼容 + strip_urls 过滤器
├── _posts/              # 文章（按年份子目录组织）
│   ├── 2019/
│   ├── 2020/
│   ├── ...
│   └── 2026/
├── assets/              # 前端资源
│   ├── css/search.css   #   搜索弹窗样式
│   └── js/search.js     #   全文搜索逻辑（索引加载、分页、弹窗）
├── files/               # 附件文件（脚本、配置等，按年份组织）
│   ├── 2025/
│   └── 2026/
├── favicons/            # Favicon 图标集
├── imgs/                # 文章图片（按主题/年份组织）
├── pages/               # 额外页面
│   └── feed.xml         #   RSS 订阅源
├── search.json          # 搜索索引（Jekyll 生成，含标题/正文/分类）
├── file-viewer.html     # 附件在线查看器页面
├── index.md             # 首页内容（简介 + DIY 工具链接）
└── 404.html             # 自定义 404 页面
```

### 环境搭建

#### Windows

1. 下载安装 **Ruby+Devkit**
   https://rubyinstaller.org/downloads/
   安装时勾选 "Add Ruby executables to PATH"

2. 安装开发工具链
   ```bash
   ridk install
   # 弹出菜单输入 3 回车，等待安装完成
   ```

3. 换源（可选，国内推荐）
   ```bash
   gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
   ```

4. 安装 Jekyll
   ```bash
   gem install jekyll bundler
   ```

5. 安装项目依赖并启动
   ```bash
   cd lzc6244.github.io
   bundle install
   bundle exec jekyll serve
   # 浏览器打开 http://127.0.0.1:4000/
   ```

> **注意**：始终用 `bundle exec jekyll` 而不是 `jekyll` 命令，确保和 Gemfile 中的版本一致

#### Ubuntu

1. 安装依赖
   ```bash
   sudo apt update
   sudo apt install ruby-full build-essential zlib1g-dev
   ```

2. 配置 gem 安装路径（避免 root 权限）
   ```bash
   echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
   echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
   echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. 换源（可选，国内推荐）
   ```bash
   gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
   ```

4. 安装 Jekyll
   ```bash
   gem install jekyll bundler
   ```

5. 安装项目依赖并启动
   ```bash
   cd /path/to/lzc6244.github.io
   bundle install
   bundle exec jekyll serve
   # 浏览器打开 http://127.0.0.1:4000/
   ```

> **注意**：始终用 `bundle exec jekyll` 而不是 `jekyll` 命令，确保和 Gemfile 中的版本一致

### 写文章

1. 在 `_posts` 目录下创建 `.md` 文件
2. 文件名格式：`年-月-日-文章标题.md`
3. 文件头部添加以下内容：

```yaml
---
layout:         post
title:          文章标题
create_time:    2026-07-06 14:30
update_time:    2026-07-07 10:00
categories:     [分类1,分类2]
---
```

各字段说明：
- `layout`：固定为 `post`
- `title`：文章标题
- `create_time`：创建时间（精确到分可选）
- `update_time`：更新时间（可选，有则显示）
- `categories`：文章分类，支持层级（如 `[Python,爬虫]`），用于首页分类导航

4. 图片放到 `imgs/` 目录，文章中引用：`![描述](/imgs/路径/图片.png)`

#### 行内代码语义样式

写文章时可用 HTML `<code class="xxx">` 标签为特定行内代码添加语义化样式（Markdown 预览中显示为普通行内代码）：

| 类名 | 用途 | 效果预览 |
|---|---|---|
| `.cmd` | 命令（docker, git, npm） | <code style="color:#3b82f6;font-weight:500">docker network inspect</code> |
| `.path` | 文件路径 | <code style="color:#b45309">/etc/docker/daemon.json</code> |
| `.flag` | 参数选项 | <code style="color:#d97706">--format</code> |
| `.val` | 值（IP、端口） | <code style="color:#059669">192.168.1.0/24</code> |
| `.key` | 按键 | <kbd>Ctrl+C</kbd> |

示例：
```html
运行 <code class="cmd">docker network inspect</code> 并传入 <code class="flag">--format</code> 参数
```

> 代码块中的 `{{ }}` 语法（如 Docker/Go 模板）会被自动转义，无需手动处理。

#### 提示框（分级提醒）

使用 `<blockquote class="xxx">` 插入带级别的提示框，Markdown 预览中显示为普通引用块。

当前支持以下四种类型：

| class 值 | 图标 | 名称 | 适用场景 |
|---|---|---|---|
| `info` | ℹ️ | 信息 | 背景知识、补充说明 |
| `tip` | 💡 | 提示 | 最佳实践、小技巧 |
| `warning` | ⚠️ | 警告 | 需注意、易踩坑 |
| `danger` | 🚨 | 危险 | 危险操作、数据丢失风险 |

文章中使用示例：
```html
<blockquote class="warning">
修改配置前建议先备份原始文件。
</blockquote>
```

实际渲染效果：

<blockquote style="border-left:4px solid #3b82f6;background:rgba(59,130,246,0.06);padding:12px 20px;border-radius:0 6px 6px 0;margin:12px 0">
<strong style="color:#3b82f6">ℹ️ 信息</strong><code style="font-size:0.85em;color:#888">.info</code> — 背景知识、补充说明
</blockquote>

<blockquote style="border-left:4px solid #10b981;background:rgba(16,185,129,0.06);padding:12px 20px;border-radius:0 6px 6px 0;margin:12px 0">
<strong style="color:#10b981">💡 提示</strong><code style="font-size:0.85em;color:#888">.tip</code> — 最佳实践、小窃门
</blockquote>

<blockquote style="border-left:4px solid #f59e0b;background:rgba(245,158,11,0.06);padding:12px 20px;border-radius:0 6px 6px 0;margin:12px 0">
<strong style="color:#f59e0b">⚠️ 警告</strong><code style="font-size:0.85em;color:#888">.warning</code> — 需注意、易踩坑
</blockquote>

<blockquote style="border-left:4px solid #ef4444;background:rgba(239,68,68,0.06);padding:12px 20px;border-radius:0 6px 6px 0;margin:12px 0">
<strong style="color:#ef4444">🚨 危险</strong><code style="font-size:0.85em;color:#888">.danger</code> — 危险操作、数据丢失风险
</blockquote>

> GitHub 上写文章时也可用原生告警语法（<code>> [!NOTE]</code> / <code>[!TIP]</code> / <code>[!WARNING]</code> / <code>[!CAUTION]</code>）获得相同效果。

#### 文字颜色标注

使用 `<span style="color:xxx">` 为文字添加颜色，Markdown 预览中显示为原始 HTML。

常用颜色：

| 颜色 | 色值 | 适用场景 | 效果预览 |
|---|---|---|---|
| 红色 | `red` | 警告、禁止操作、危险提示 | <span style="color:red">重启前务必保留当前连接</span> |
| 橙色 | `orange` | 注意事项、需关注 | <span style="color:orange">此操作耗时较长</span> |
| 绿色 | `green` | 成功、推荐操作 | <span style="color:green">配置已生效</span> |
| 蓝色 | `#3b82f6` | 信息补充、链接说明 | <span style="color:#3b82f6">参见官方文档</span> |
| 紫色 | `purple` | 备注、特殊说明 | <span style="color:purple">仅限开发环境</span> |
| 灰色 | `gray` | 次要信息、已废弃 | <span style="color:gray">此方法已不推荐</span> |

示例：
```html
<span style="color:red">ssh 连不上就完了，这样还能用已有 ssh 连接进行挽救</span>
```

#### 附件在线预览

文章引用 `files/` 目录下的配置文件、脚本等附件时，使用在线查看器格式，点击后可在浏览器中直接预览内容（而非下载或乱码）：

```markdown
[文件名](/file-viewer/?file=/files/路径/文件名)
```

- 支持所有文本类型文件：`.sh`、`.yaml`、`.yml`、`.conf`、`.json`、`.py`、`.sql` 等
- 查看器页面提供「下载文件」按钮，方便直接保存
- 历史直接链接 `/files/xxx` 仍保持原行为（下载或原生显示）

### 引用本站文章

使用 Jekyll 的 `post_url` 标签引用文章，构建时自动解析为正确链接（无需记忆 permalink 格式，且引用不存在时构建会报错）：

```liquid
[显示文字]({% post_url 年份目录/文件名不含扩展名 %})
```

示例：
```markdown
[docker 查看已有网络的内网 ip]({% post_url 2025/2025-02-22-docker-查看已有网络的内网-ip %})
```

> `post_url` 中的路径即 `_posts/` 下的子目录 + 文件名（不含 `.md`），如 `_posts/2025/2025-02-22-docker-查看已有网络的内网-ip.md` → `2025/2025-02-22-docker-查看已有网络的内网-ip`。

### 本地预览

写文章时，保持 `jekyll serve` 在后台运行：

```bash
cd lzc6244.github.io
bundle exec jekyll serve
# 浏览器打开 http://127.0.0.1:4000/
```

- **修改文章**：编辑 `_posts/` 下的 `.md` 文件，保存后刷新浏览器即可看到变化
- **新增文章**：在 `_posts/` 下新建 `.md` 文件，Jekyll 会自动检测并重新生成
- **添加图片**：直接把图片文件拖入 `imgs/` 目录（如 `imgs/python/2026/截图.png`），文章中引用 `![说明](/imgs/python/2026/截图.png)`，**不需要 commit 到 git**，本地就能立即显示
- **添加附件**：将文件放入 `files/` 目录（如 `files/2026/script.sh`），文章中用 `[文件名](/file-viewer/?file=/files/2026/script.sh)` 引用可在线预览
- **修改配置**：改了 `_config.yml` 需要重启 `jekyll serve` 才会生效

### 清理构建缓存

如果遇到页面未更新、样式错乱或 header 重复显示等问题，需要清理历史构建并重新生成：

```bash
# 停掉当前服务（Ctrl + C）
# 删除历史构建文件
rm -rf _site

# 重新构建并启动
bundle exec jekyll serve
```

> 改了 `_config.yml` 或新增/删除了大量文件后，建议 `rm -rf _site` 后重启，避免增量构建产生缓存冲突

### Disqus 评论

每篇文章底部自动加载 Disqus 评论区，由 `_config.yml` 中的 `disqus.shortname` 控制：

```yaml
disqus:
  shortname: your-shortname
```

- **启用**：填写你的 Disqus shortname 即可，所有文章页面自动显示评论区
- **关闭**：将 `shortname` 留空或删除整个 `disqus` 配置块，评论区不会出现
- **本地预览**：`jekyll serve` 本地运行时 Disqus 也能正常加载，但需确保网络能访问 Disqus 服务
- **模板位置**：`_layouts/post.html` 中通过 `{% if site.disqus.shortname %}` 条件引入 `disqus_comments.html`

### 配置修改

编辑 `_config.yml` 文件，可修改：
- 博客标题、描述、作者
- 社交链接（GitHub、知乎）
- 头像路径、Favicon 路径
- Minima 皮肤（`auto` / `classic` / `dark`）
- Disqus 评论 shortname
- Google Analytics ID
- 文章永久链接格式（permalink）
- Jekyll 插件列表

### 技术栈

- **Jekyll 3.9** + **Minima 2.5** 主题（深度定制简约清爽风格）
- **Liquid 模板引擎**（>= 4.0.4，兼容 Ruby 4.0）
- **kramdown-parser-gfm** — GitHub Flavored Markdown 解析
- **Inter 字体**（Google Fonts）+ **JetBrains Mono** 代码字体
- **CSS Custom Properties** 设计令牌体系，clamp() 响应式排版
- **自定义 Jekyll 插件**（Ruby）— Liquid 转义、分类过滤、Ruby 兼容
- **GitHub Pages** 自动构建部署
