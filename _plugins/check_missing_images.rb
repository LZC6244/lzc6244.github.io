# 构建时检查文章中引用的本地图片是否存在
#
# 扫描所有文章的 Markdown 图片语法 ![](/path) 和 HTML <img src="/path">，
# 对本地路径（以 / 开头）检查文件是否存在，缺失时在构建输出中打印警告。
Jekyll::Hooks.register :site, :post_write do |site|
  missing = []

  site.posts.docs.each do |post|
    content = post.content
    next unless content

    # Markdown 图片：![alt](/local/path)
    content.scan(/!\[[^\]]*\]\((\/[^)\s]+)(?:\s+"[^"]*")?\)/) do |match|
      img_path = match[0]
      file = File.join(site.source, img_path)
      unless File.file?(file)
        missing << [post.relative_path, img_path]
      end
    end

    # HTML img 标签：<img src="/local/path">
    content.scan(/<img[^>]+src=["'](\/[^"']+)["']/) do |match|
      img_path = match[0]
      file = File.join(site.source, img_path)
      unless File.file?(file)
        missing << [post.relative_path, img_path]
      end
    end
  end

  unless missing.empty?
    Jekyll.logger.warn "Missing images:", "#{missing.size} file(s) not found"
    missing.each do |post_path, img_path|
      Jekyll.logger.warn "", "  #{post_path}  =>  #{img_path}"
    end
  end
end
