require_relative 'environment'

class Evaluator
  def initialize
    @environment = Environment.new
  end

  # node を受け取って再帰的に評価する
  def evaluate(node)
    case node
    when Node::Integer, Node::Boolean
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
    when Node::Block
      eval_block(node)
    else
      raise "Unknown node type: #{node.class}"
    end
  end

  def variables = @environment.all_variables

  private

  # 2項演算の評価
  def eval_binary_op(lhs, op, rhs)
    case op
    when :plus then lhs + rhs
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

  def eval_block(node)
    return nil if node.statements.empty?

    node.statements.map { |statement| evaluate(statement) }.last
  end

  def ensure_boolean!(cond_result, context = "The condition of an if")
    unless boolean?(cond_result)
      raise "#{context} statement must be a boolean: #{cond_result}"
    end
  end

  def boolean?(cond_result) = cond_result.is_a?(TrueClass) || cond_result.is_a?(FalseClass)
end

__END__
x = 42
x = 1 + 3

