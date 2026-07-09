# 构建时检查文章所在文件夹年份是否与文件名日期年份一致
#
# 文章路径形如 _posts/2025/2025-01-18-xxx.md，若文件名年份与文件夹年份不一致则打印警告。
Jekyll::Hooks.register :site, :post_write do |site|
  mismatched = []

  site.posts.docs.each do |post|
    # relative_path 形如 _posts/2026/2025-11-16-xxx.md
    rel = post.relative_path.to_s
    # 提取文件夹年份（_posts/YYYY/...）
    folder_year = rel[%r{_posts/(\d{4})/}, 1]
    # 提取文件名年份（YYYY-MM-DD-...）
    file_year = File.basename(rel)[/^(\d{4})/, 1]

    next unless folder_year && file_year
    if folder_year != file_year
      mismatched << {
        path: rel,
        folder: folder_year,
        file: file_year
      }
    end
  end

  unless mismatched.empty?
    Jekyll.logger.warn "Year mismatch:", "#{mismatched.size} post(s) in wrong folder"
    mismatched.each do |item|
      Jekyll.logger.warn "",
        "  #{item[:path]}  (folder: #{item[:folder]}, file: #{item[:file]} → should be _posts/#{item[:file]}/)"
    end
  end
end
