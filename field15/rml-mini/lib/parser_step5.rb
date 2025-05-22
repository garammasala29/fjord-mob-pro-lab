require_relative 'lexer'
require_relative 'node'

class ParserStep5
  def self.parse(input)
    new(input).parse
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def parse
    # :TODO: 式から始めていたのを変える
    result = # ???

    # エラー処理
    if @current_token.type != :eol
      raise "Unexpected token: #{@current_token.value}"
    end

    result
  end

  private

  def statement
    # :TODO:
  end

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
    # :TODO:
  end

  # 次のトークンを消費せずに確認するヘルパーメソッド
  def peek_next_token
    @lexer.peek_token
  end

  def consume(expected_type)
    if @current_token.type != expected_type
      raise "Expected #{expected_type}, got: #{@current_token.type}"
    end

    @current_token = @lexer.next_token
  end
end
