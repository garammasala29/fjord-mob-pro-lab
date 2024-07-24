module Browser
  def rurema(class_name)
    browser_path = ENV['BROWSER']
    url = "https://docs.ruby-lang.org/ja/latest/class/#{class_name}.html"
    case RUBY_PLATFORM
    when /linux/
      if browser_path
        fork { exec browser_path, url }
      else
        fork { exec 'xdg-open', url, err:'/dev/null' }
      end
    when /darwin|mac OS/
      fork { exec 'open', url }
    end
  end
end
include Browser
