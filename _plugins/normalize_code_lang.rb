# 自动规范化围栏代码块的语言标识符
#
# kramdown 不支持含空格或大小写不规范的语言标识符（如 ```Plain Text、```Dockerfile），
# 会导致代码块无法正确渲染。本插件在渲染前自动修正：
#   - 已知映射："Plain Text" → "text"，"C++" → "cpp" 等
#   - 含空白的标识符：去掉空格并转小写
#   - 其余一律转小写（如 "Dockerfile" → "dockerfile"）
# 同时支持 ``` 和 ~~~ 两种围栏标记（有序列表内的代码块会被自动转为 ~~~）
Jekyll::Hooks.register :posts, :pre_render do |post|
  next unless post.content

  normalize = {
    'plain text'  => 'text',
    'plain'       => 'text',
    'java script' => 'javascript',
    'c sharp'     => 'csharp',
    'c++'         => 'cpp',
    'objective c' => 'objectivec',
    'shell script'=> 'bash',
  }

  # 匹配 ``` 或 ~~~ 后紧跟的语言标识符行（允许前导空白）
  post.content = post.content.gsub(/^([ \t]*(?:```|~~~))(.+?)[ \t]*$/) do
    prefix = $1
    lang   = $2.strip
    lower  = lang.downcase
    matched = $&  # 必须在其他正则操作前保存，避免 $& 被后续 =~ 覆盖

    if normalize.key?(lower)
      "#{prefix}#{normalize[lower]}"
    elsif lang =~ /\s/
      # 含空格标识符：去掉空格并转小写
      "#{prefix}#{lang.gsub(/\s+/, '').downcase}"
    elsif lang != lower
      # 含大写字母：转小写
      "#{prefix}#{lower}"
    else
      matched  # 无需修改：直接返回原匹配（不可用 $&，因后续 gsub 替换字符串中 $&\d 会被误解析为反向引用）
    end
  end
end
