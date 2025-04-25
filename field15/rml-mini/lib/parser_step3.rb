require_relative 'lexer'

class ParserStep3
  def self.eval(input)
    new(input).eval
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def eval
    result = expr

    if @current_token.type != :eof
      raise "Unexpected token: #{@current_token.value}"
    end

    result
  end

  private

  def expr
    result = term

    while %i[plus minus].include?(@current_token.type)
      op = @current_token.type
      consume(op)
      rhs = term

      case op
      when :plus then result += rhs
      when :minus then result -= rhs
      end
    end

    result
  end

  def term
    result = factor

    while %i[asterisk slash].include?(@current_token.type)
      op = @current_token.type
      consume(op)

      rhs = factor

      case op
      when :asterisk then result *= rhs
      when :slash then result /= rhs
      end
    end

    result
  end

  def factor
    unless @current_token != :int
      raise "Expected interger, got: #{@current_token.type}"
    end

    value = @current_token.value
    consume(:int)

    value
  end

  def consume(expected_type)
    if @current_token.type == expected_type
      @current_token = @lexer.next_token
    else
      raise "Expected #{expected_type}, got: #{@current_token.type}"
    end
  end
end
