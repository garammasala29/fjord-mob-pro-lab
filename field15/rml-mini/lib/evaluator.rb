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
      # environmentから識別子の名前で値を探して返す
      @environment.lookup(node.name)
    when Node::Assignment
      # environmentに変数と値のペアを登録したい
      # 環境のマッピングの中にすでに変数名が存在していれば assign を読んで代入
      # 初回だったらdefine
      value = evaluate(node.value)
      if @environment.var_exists?(node.name)
        @environment.assign(node.name, value)
      else
        @environment.define(node.name, value)
      end

      value
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
    when Node::ReturnStatement
      eval_return_statement(node)
    when Node::FunctionCall
      eval_function_call(node)
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
        to_str(lhs) + to_str(rhs)
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

    if cond_result
      evaluate(node.then_body)
    else
      node.else_ifs.each do |else_if|
        else_if_cond_result =  evaluate(else_if.condition)

        ensure_boolean!(else_if_cond_result, "The condition of an else-if")

        if else_if_cond_result
          return evaluate(else_if.body)
        end
      end

      if node.else_body
        evaluate(node.else_body)
      end
    end
  end

  def eval_while_statement(node)
    result = nil
    count = 0
    loop do
      if count > MAX_LOOP_ITERATIONS
        raise "Loop exceeded maximum iterations (#{MAX_LOOP_ITERATIONS}). Possible infinite loop detected."
      end

      cond_result = evaluate(node.condition)
      ensure_boolean!(cond_result, "The condition of a while")
      break unless cond_result

      result = evaluate(node.body)
      count += 1
    end

    result
  end

  def eval_hyouji_statement(node)
    result = evaluate(node.expression)
    puts format_for_output(result)
  end

  def eval_block(node)
    return nil if node.statements.empty?

    node.statements.map { |statement| evaluate(statement) }.last
  end

  def eval_function_def(node)
    @environment.define_function(node)

    node.name
  end

  def eval_return_statement(node)
    value = node.expression ? evaluate(node.expression) : nil

    raise ReturnException.new(value)
  end

  def eval_function_call(node)
    function = @environment.lookup_function(node.name)
    raise "Wrong number of arguments for '#{node.name}': expected #{function.params.size}, got #{node.arguments.size}" if node.arguments.size != function.params.size

    argument_values = node.arguments.map { evaluate(_1) }

    function_env = Environment.new(@environment)

    function.params.zip(argument_values) do |param, value|
      function_env.define(param, value)
    end

    prev_env = @environment
    @environment = function_env
    @recursion_depth += 1

    begin
      evaluate(function.body)
    rescue ReturnException => e
      e.value
    ensure
      @environment = prev_env
      @recursion_depth -= 1
    end
  end

  def ensure_boolean!(cond_result, context = "The condition of an if")
    unless boolean?(cond_result)
      raise "#{context} statement must be a boolean: #{cond_result}"
    end
  end

  def boolean?(cond_result) = cond_result.is_a?(TrueClass) || cond_result.is_a?(FalseClass)

  def format_for_output(value)
    case value
    when String, Integer, TrueClass, FalseClass
      value.to_s
    when NilClass
      "nil"
    else
      value.to_s
    end
  end

  def to_str(value)
    case value
    when String, Integer, TrueClass, FalseClass
      value.to_s
    when NilClass
      "nil"
    else
      value.to_s
    end
  end

  def string?(value)
    value.is_a?(String)
  end
end

__END__
x = 42
x = 1 + 3
