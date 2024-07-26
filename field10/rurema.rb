module Browser
  def rurema(class_name, method_name = nil)
    if Object.const_defined?(class_name)
      klass = Object.const_get(class_name)
    else
      puts "#{class_name} is not found"
      return
    end
    if method_name
      if klass.instance_methods.include?(method_name)
        category = 'i'
        owner_class = klass.instance_method(method_name).owner
      elsif klass.singleton_methods.include?(method_name)
        category = 's'
        owner_class = klass.singleton_method(method_name).owner
      else
        puts "#{klass}##{method_name} not found"
        return
      end

      converted_method_name = method_name.to_s.chars.map do |c|
        /\w/ =~ c ? c : sprintf("=%x",c.ord)
      end.join

      url = "https://docs.ruby-lang.org/ja/latest/method/#{owner_class}/#{category}/#{converted_method_name}.html"
    else
      url = "https://docs.ruby-lang.org/ja/latest/class/#{class_name}.html"
    end

    browser_path = ENV['BROWSER']
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
