source "https://rubygems.org"

# GitHub Pages 线上使用 Ruby 3.3.4，可正常安装 github-pages 232（含 liquid 4.0.4）
# 本地 Ruby 4.0+ 无法安装 github-pages 232（commonmarker 限制），使用直接依赖
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0.0")
  gem "jekyll", "~> 3.9"
  gem "minima", "~> 2.5"
  gem "liquid", ">= 4.0.4"   # 修复 Ruby 3.4+ untaint 兼容问题
  gem "kramdown-parser-gfm"
  gem "webrick"
  gem "csv"
  gem "base64"
  gem "bigdecimal"

  group :jekyll_plugins do
    gem "jekyll-sitemap"
    gem "jekyll-seo-tag"
    gem "jekyll-feed"
  end
else
  gem "github-pages", group: :jekyll_plugins
end

gem "wdm", ">= 0.1.0" if Gem.win_platform?  # Windows 文件监控优化
