# 自动转义代码中的 Liquid 语法冲突 + 修复有序列表内代码块
#
# 在 Liquid 渲染前，自动处理：
#   1. 有序列表项内的 ``` 围栏代码块转换为 ~~~
#      （kramdown 缩进 ``` 会被当作普通代码块，~~~ 不受此影响）
#   2. 围栏代码块（```...```）中的 {{ }} 添加 {% raw %} 保护
#   3. 反引号行内代码（`...`）中的 {{ }} 添加 {% raw %} 保护
#   4. HTML code 标签（<code class="...">...）中的 {{ }} 添加 {% raw %} 保护
#
# 原理：{% raw %} 在 Liquid 阶段被移除，不会进入 Markdown/HTML 层。
# 效果：写文章时可直接在代码中使用 {{ }}，无需手动处理。
Jekyll::Hooks.register :posts, :pre_render do |post|
  next unless post.content

  # ── 有序列表项内的 ``` 转换为 ~~~ ──
  # 逐行解析，跟踪有序列表上下文，将缩进的 ``` 围栏标记替换为 ~~~
  lines = post.content.split("\n", -1)
  result = []
  in_ol = false
  in_fenced_block = false

  lines.each do |line|
    if in_fenced_block
      if line =~ /\A[ ]{3}(`{3,})\s*\z/
        result << line.sub(/`{3}/, '~~~')
        in_fenced_block = false
      else
        result << line
      end
    elsif line =~ /\A\d+\.\s/
      in_ol = true
      result << line
    elsif in_ol && line =~ /\A[ ]{3}(`{3,})/
      result << line.sub(/`{3}/, '~~~')
      in_fenced_block = true
    elsif in_ol && (line =~ /\A\s*$/ || line =~ /\A[ ]{3}/)
      result << line
    else
      in_ol = false
      result << line
    end
  end
  post.content = result.join("\n")

  # ── 围栏代码块 Liquid 转义 ──
  # 用 {% raw %} 包裹剩余的 ``` 代码块（. 在 m 模式下匹配换行符）
  post.content = post.content.gsub(/(```.+?```)/m) do
    "{% raw %}\n#{$1}\n{% endraw %}"
  end

  # ── 行内代码 Liquid 转义 ──
  # 反引号行内代码：为每对 {{...}} 添加 {% raw %} 保护
  post.content = post.content.gsub(/(`[^`\n]+`)/) do
    $1.gsub(/(\{\{[^}]*\}\})/, '{% raw %}\1{% endraw %}')
  end

  # HTML <code> 标签：为每对 {{...}} 添加 {% raw %} 保护
  post.content = post.content.gsub(/(<code[^>]*>.+?<\/code>)/m) do
    $1.gsub(/(\{\{[^}]*\}\})/, '{% raw %}\1{% endraw %}')
  end
end
