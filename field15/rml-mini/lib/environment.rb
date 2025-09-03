class Environment
  def initialize(parent = nil)
    @values = {}
    @functions = {}
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
      @parent.lookup(name, value)
    else
      raise "未定義の変数です: #{name}"
    end
  end

  def define_function(function_def_node)
    @functions[function_def_node.name] = function_def_node
  end

  def lookup_function(name)
    if @functions.key?(name)
      @functions[name]
    elsif @parent
      @parent.lookup_function(name)
    else
      raise "未定義の関数です: #{name}"
    end
  end

  def var_exists?(name)
    @values.key?(name) || (@parent && @parent.var_exists?(name))
  end

  def all_variables
    vars = @values.dup
    vars.merge!(@parent.all_variables) if @parent

    vars
  end
end
