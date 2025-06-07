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
    when Node::Block
      eval_block(node)
    else
      raise "Unknown node type: #{node.class}"
    end
  end

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

  def eval_block(node)
    return nil if node.statements.empty?

    node.statements.map { |statement| evaluate(statement) }.last
  end

  def ensure_boolean!(value, context = "The condition of an if")
    unless boolean?(value)
      raise "#{context} statement must be a boolean: #{value}"
    end
  end

  def boolean?(value) = value.is_a?(TrueClass) || value.is_a?(FalseClass)
end
