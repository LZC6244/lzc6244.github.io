# 过滤 _posts 子目录自动注入的分类
# Jekyll 会将 _posts 下的子目录名作为分类添加到文章中，
# 此插件在文章初始化后移除所有来自目录结构的分类，
# 仅保留 front matter 中显式定义的分类。
Jekyll::Hooks.register :posts, :post_init do |post|
  # 提取 _posts 与文件名之间的所有子目录名
  rel = post.relative_path.to_s
  dir_cats = rel.split("/")[1...-1]  # 去掉 "_posts" 和文件名
  cats = post.data["categories"] || []
  cats.reject! { |c| dir_cats.include?(c) }
  post.data["categories"] = cats
end
