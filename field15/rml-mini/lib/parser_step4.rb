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

  def eval
    # ASTを構築し、評価する
    ast = expr

    # エラー処理
    if @current_token != :eof
      raise "Unexpected token: #{@current_token.value}"
    end

    ast
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
