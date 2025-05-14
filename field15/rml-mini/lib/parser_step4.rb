require_relative 'lexer'
require_relative 'node'

class ParserStep4
  def self.eval(input)
    new(input).eval
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def eval
    # ASTを構築し、評価する
    ast = expr

    # エラー処理

    ast.evaluate
  end

  private
  # 以下は再帰下降構文解析
  def expr
    # :TODO:
  end

  def term
    # :TODO:
  end

  def factor
    # :TODO:
  end

  def consume(expected_type)
    # :TODO:
  end
end
