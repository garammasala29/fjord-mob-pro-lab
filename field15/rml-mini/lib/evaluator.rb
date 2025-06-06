require_relative 'environment'

class Evaluator
  # node を受け取って再帰的に評価する
  def evaluate(node)
    case node
    when Node::Integer
      node.value
    when Node::BinaryOp
      lhs = evaluate(node.lhs)
      rhs = evaluate(node.rhs)
      eval_binary_op(lhs, node.op, rhs)
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
end
