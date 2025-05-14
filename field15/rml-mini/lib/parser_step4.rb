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
    if @current_token.type != :eof
      raise "Unexpected token: #{@current_token.value}"
    end

    ast
  end

  private
  # 以下は再帰下降構文解析
  def expr
    result = term

    while %i[plus minus].include?(@current_token.type)
      op = @current_token.type
      consume(op)
      rhs = term

      result = Node::BinaryOp.new(result, op, rhs)
    end

    result
  end

  def term
    result = factor

    while %i[asterisk slash].include?(@current_token.type)
      op = @current_token.type
      consume(op)
      rhs = factor

      result = Node::BinaryOp.new(result, op, rhs)
    end

    result
  end

  def factor
    token = @current_token

    case token.type
    when :int
      consume(:int)

      Node::Integer.new(token.value)
    when :l_paren
      consume(:l_paren)
      result = expr # かっこの中は式がある
      consume(:r_paren)

      result
    else
      raise "Expected integer or '(', got: #{token.type}"
    end
  end

  def consume(expected_type)
    if @current_token.type != expected_type
      raise "Expected #{expected_type}, got: #{@current_token.type}"
    end

    @current_token = @lexer.next_token
  end
end
