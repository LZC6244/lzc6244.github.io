# Fix Ruby 3.4+ compatibility for old Liquid/Jekyll versions
# String#untaint was removed in Ruby 3.2
class String
  def untaint
    self
  end
end if !"".respond_to?(:untaint)

# Strip URLs, markdown links and images from content for search index
module Jekyll
  module URLStripper
    def strip_urls(input)
      input.to_s
        .gsub(/!\[[^\]]*\]\([^)]*\)/, '')          # remove markdown images ![alt](url)
        .gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')        # markdown links [text](url) → text
        .gsub(%r{https?://[^\s<"')\]]+}, '')         # remove bare URLs
    end
  end
end

Liquid::Template.register_filter(Jekyll::URLStripper)
