class Token
  attr_reader :type, :value

  def initialize(type, value = nil)
    @type = type
    @value = value
  end
end

class Lexer
  def initialize(input)
    @input = input
    @index = 0
  end

  def next_token
    skip_whitespace
    return Token.new(:eof) if eof?

    case current_char
    when /\d/ then read_number
    when '+' then advance; Token.new(:plus)
    when '-' then advance; Token.new(:minus)
    when '*' then advance; Token.new(:asterisk)
    when '/' then advance; Token.new(:slash)
    else
      raise "Unknown character: #{current_char}"
    end
  end

  private

  def skip_whitespace
    advance while current_char&.match?(/\s/)
  end

  def current_char
    @input[@index]
  end

  def advance
    @index += 1
  end

  def read_number
    start_index = @index
    advance while current_char&.match?(/\d/)

    Token.new(:int, @input[start_index...@index].to_i)
  end

  def eof?
    @index >= @input.size
  end
end
