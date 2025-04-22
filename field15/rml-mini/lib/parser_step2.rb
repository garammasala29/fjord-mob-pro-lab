# STEP2(このステップではlexerも自分で考えて実装しよう`lexer.rb`)
require_relative 'lexer'

class ParserStep2
  BINARY_OPERATORS = %i[plus minus asterisk slash]

  def self.eval(input)
    new(input).eval
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def eval
    # TODO: ここに実装を書く
    lhs = consume_int

    while BINARY_OPERATORS.include? @current_token.type
      operator = @current_token
      advance
      rhs = consume_int
      lhs = evaluate(lhs, operator, rhs)
    end

    lhs
  end

  private

  def consume_int
    unless @current_token.type == :int
      raise "Expected integer but got #{@current_token.type}"
    end

    value = @current_token.value
    advance

    value
  end

  def advance
    @current_token = @lexer.next_token
  end

  def evaluate(lhs, op, rhs)
    case op.type
    when :plus then lhs + rhs
    when :minus then lhs - rhs
    when :asterisk then lhs * rhs
    when :slash then lhs / rhs
    else
      raise "Unknown operator: #{op.value}"
    end
  end
end
