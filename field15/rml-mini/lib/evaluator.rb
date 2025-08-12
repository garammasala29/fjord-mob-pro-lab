require_relative 'environment'

class Evaluator
  class ReturnException < StandardError
    attr_reader :value

    def initialize(value)
      @value = value
      super
    end
  end

  # 無限ループ対策のための実行ステップ制限
  MAX_LOOP_ITERATIONS = 10000
  MAX_RECURSION_DEPTH = 1000

  def initialize
    @environment = Environment.new
    @recursion_depth = 0
  end

  # node を受け取って再帰的に評価する
  def evaluate(node)
    case node
    when Node::Integer, Node::Boolean, Node::String
      node.value
    when Node::Variable
      @environment.lookup(node.name)
    when Node::Assignment
      value = evaluate(node.value)

      if @environment.var_exists?(node.name)
        @environment.assign(node.name, value)
      else
        @environment.define(node.name, value)
      end

      value # 割り当てられた値を戻り値として返す
    when Node::BinaryOp
      lhs = evaluate(node.lhs)
      rhs = evaluate(node.rhs)

      eval_binary_op(lhs, node.op, rhs)
    when Node::ComparisonOp
      lhs = evaluate(node.lhs)
      rhs = evaluate(node.rhs)

      eval_comparison_op(lhs, node.op, rhs)
    when Node::IfStatement
      eval_if_statement(node)
    when Node::WhileStatement
      eval_while_statement(node)
    when Node::HyoujiStatement
      eval_hyouji_statement(node)
    when Node::Block
      eval_block(node)
    when Node::FunctionDef
      eval_function_def(node)
    when Node::FunctionCall
      eval_function_call(node)
    when Node::ReturnStatement
      eval_return_statement(node)
    else
      raise "Unknown node type: #{node.class}"
    end
  end

  def variables = @environment.all_variables

  private

  # 2項演算の評価
  def eval_binary_op(lhs, op, rhs)
    case op
    when :plus
      if string?(lhs) || string?(rhs)
        to_str(lhs) + to_str(rhs) # 文字列連結(暗黙の型変換を含む)
      else
        lhs + rhs
      end
    when :minus then lhs - rhs
    when :asterisk then lhs * rhs
    when :slash then lhs / rhs
    else
      raise "Unknown operator: #{op}"
    end
  end

  # 比較の2項演算の評価
  def eval_comparison_op(lhs, op, rhs)
    case op
    when :equal_equal then lhs == rhs
    when :not_equal then lhs != rhs
    when :less then lhs < rhs
    when :greater then lhs > rhs
    when :equal_less then lhs <= rhs
    when :equal_greater then lhs >= rhs
    else
      raise "Unknown comparison operator: #{op}"
    end
  end

  def eval_if_statement(node)
    cond_result = evaluate(node.condition)
    ensure_boolean!(cond_result, "The condition of an if")

    if cond_result # 条件式がtrueの場合
      evaluate(node.then_body)
    else # 条件式がfalseの場合
      node.else_ifs.each do |else_if|
        elseif_cond = evaluate(else_if.condition)
        ensure_boolean!(elseif_cond, "The condition of an else-if")

        if elseif_cond # trueの処理
          return evaluate(else_if.body)
        end
      end

      # else節あれば評価する
      node.else_body ? evaluate(node.else_body) : nil
    end
  end

  def eval_while_statement(node)
    iteration_count = 0
    result = nil

    loop do
      if iteration_count >= MAX_LOOP_ITERATIONS
        raise "Loop exceeded maximum iterations (#{MAX_LOOP_ITERATIONS}). Possible infinite loop detected."
      end

      cond_result = evaluate(node.condition)
      ensure_boolean!(cond_result, "The condition of a while")

      break unless cond_result # falseならループ抜ける

      result = evaluate(node.body)
      iteration_count += 1
    end

    result
  end

  def eval_hyouji_statement(node)
    value = evaluate(node.expression)
    puts format_for_output(value)
  end

  def eval_block(node)
    return nil if node.statements.empty?

    node.statements.map { |statement| evaluate(statement) }.last
  end

  def eval_function_def(node)
    @environment.define_function(node)

    node.name
  end

  def eval_function_call(node)
    if @recursion_depth >= MAX_RECURSION_DEPTH
      raise "Maximum recursion depth exceeded (#{MAX_RECURSION_DEPTH})"
    end

    function_def = @environment.lookup_function(node.name)

    # 引数の数をチェック
    unless node.arguments.size == function_def.parameters.size
      raise "Wrong number of arguments for '#{node.name}': expected #{function_def.parameters.size}, got #{node.arguments.size}"
    end

    argument_values = node.arguments.map { evaluate(it) }

    function_env = Environment.new(@environment)

    function_def.parameters.zip(argument_values) do |param, value|
      function_env.define(param, value)
    end

    prev_env = @environment
    @environment = function_env
    @recursion_depth += 1

    begin
      evaluate(function_def.body)
    rescue ReturnException => e
      e.value
    ensure
      @environment = prev_env
      @recursion_depth -= 1
    end
  end

  def eval_return_statement(node)
    value = node.expression ? evaluate(node.expression) : nil

    raise ReturnException.new(value)
  end

  def ensure_boolean!(value, context = "The condition of an if")
    unless boolean?(value)
      raise "#{context} statement must be a boolean: #{value}"
    end
  end

  def boolean?(value) = value.is_a?(TrueClass) || value.is_a?(FalseClass)

  def string?(value) = value.is_a?(String)

  # 値を文字列に変換
  def to_str(value)
    case value
    when String then value
    when Integer then value.to_s
    when TrueClass then "true"
    when FalseClass then "false"
    when NilClass then "nil"
    else value.to_s
    end
  end

  # 出力用のフォーマット
  def format_for_output(value)
    case value
    when String then value
    when Integer then value.to_s
    when TrueClass then "true"
    when FalseClass then "false"
    when NilClass then "nil"
    else value.to_s
    end
  end

  def no_variables? = @environment.empty?
end
