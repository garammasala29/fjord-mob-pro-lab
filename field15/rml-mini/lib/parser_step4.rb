require_relative 'lexer'
require_relative 'node'

# このStep4からParserの中で評価するのではなく、評価はEvaluatorクラスへと責務を分離する
class ParserStep4
  # メソッドがevalからparseに変更されている
  def self.parse(input)
    new(input).parse
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def parse
    # ASTを構築し、評価する
    ast = expr

    # エラー処理
    if @current_token.type != :eol
      raise "Unexpected token: #{@current_token.value}"
    end

    ast
  end

  private
  # 以下は再帰下降構文解析
  def expr
    # termを読んで、左辺とする
    result = term

    while %i[plus minus].include?(@current_token.type)
      # 現在のトークンから演算子を読み込んで変数で保持
      type = @current_token.type
      # 演算子を消費する
      advance(type)
      # term　を呼んで右辺とする
      rhs = term
      # 演算子を見て、処理する
      result = Node::BinaryOp.new(result,type,rhs)
    end
    result
  end

  def term
    # factorを呼んで左辺とする
    result = factor
    # * or / の演算子がある限り、処理
    while %i[asterisk slash].include?(@current_token.type)
      # 現在のトークンから演算子を読み込んで変数で保持
      type = @current_token.type
      # 演算子を消費する
      advance(type)
      # factor　を呼んで右辺とする
      rhs = factor
      # 演算子を見て、処理する
      result = Node::BinaryOp.new(result,type,rhs)
    end
    result
  end

  def factor
    node = nil
    if @current_token.type == :int
      node = Node::Integer.new(@current_token.value)
      advance(:int)
    elsif @current_token.type == :l_paren
      advance(:l_paren)
      node = expr
      advance(:r_paren)
    end
    node
  end

  def advance(expected_type)
    raise "Unexpected token: #{@current_token.value}" unless @current_token.type == expected_type
    @current_token = @lexer.next_token
  end
end

__END__
# <Node::BinaryOp
# @lhs=#<Node::Integer @value=3>,
# @op=:asterisk,
# @rhs=#<Node::BinaryOp
    # @lhs=#<Node::Integer @value=3>,
    # @op=:plus,
    # @rhs=#<Node::Integer @value=4>
  # >
# >
