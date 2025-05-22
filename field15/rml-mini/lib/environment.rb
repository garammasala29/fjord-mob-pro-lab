class Environment
  def initialize(parent = nil)
    @values = {}
    @parent = parent
  end

  def define(name, value)
    @values[name] = value
  end

  def assign(name, value)
    if @values.key?(name)
      @values[name] = value
    elsif @parent
      @parent.assign(name, value)
    else
      raise "未定義の変数です: #{name}"
    end
  end

  def lookup(name)
    if @values.key?(name)
      @values[name]
    elsif @parent
      @parent.lookup(name)
    else
      raise "未定義の変数です: #{name}"
    end
  end
end
