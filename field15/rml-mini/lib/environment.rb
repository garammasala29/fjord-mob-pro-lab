class Environment
  def initialize(parent = nil)
    @values = {}
    @functions = {}
    @parent = parent
  end

  # 変数の定義
  def define(name, value)
    @values[name] = value
  end

  # 変数への再代入
  def assign(name, value)
    if @values.key?(name)
      @values[name] = value
    elsif @parent
      @parent.assign(name, value)
    else
      raise "未定義の変数です: #{name}"
    end
  end

  # 参照
  def lookup(name)
    if @values.key?(name)
      @values[name]
    elsif @parent
      @parent.lookup(name)
    else
      raise "未定義の変数です: #{name}"
    end
  end

  def var_exists?(name) = @values.key?(name) || (@parent && @parent.var_exists?(name))

  def all_variables
    vars = @values.dup
    vars.merge!(@parent.all_variables) if @parent

    vars
  end

  def empty? = @values.empty? && @functions.empty?

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

  def function_exists?(name) = @functions.key?(name) || (@parent && @parent.function_exists?(name))

  def all_functions
    funcs = @functions.dup
    funcs.merge!(@parent.all_functions) if @parent

    funcs
  end
end
