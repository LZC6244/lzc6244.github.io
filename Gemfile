source "https://rubygems.org"

gem "jekyll", "~> 3.9"
gem "minima", "~> 2.5"
gem "liquid", ">= 4.0.4"   # 修复 Ruby 3.4+ untaint 兼容问题
gem "webrick"              # Ruby 3.0+ 需要
gem "csv"                  # Ruby 3.4+ 需要
gem "base64"               # Ruby 3.4+ 需要
gem "bigdecimal"           # Ruby 3.4+ 需要
gem "kramdown-parser-gfm"   # Markdown 解析

gem "wdm", ">= 0.1.0" if Gem.win_platform?  # Windows 文件监控优化

group :jekyll_plugins do
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
  gem "jekyll-feed"
end
