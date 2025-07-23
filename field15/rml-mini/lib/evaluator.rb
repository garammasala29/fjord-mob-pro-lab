require_relative 'environment'

class Evaluator
  def initialize
    @environment = Environment.new
  end

  # node を受け取って再帰的に評価する
  def evaluate(node)
    case node
    when Node::Integer
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

__END__
x = 42
x = 1 + 3

