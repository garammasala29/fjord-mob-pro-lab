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
    return Token.new(:eol) if eol?

    case current_char
    when /\d/ then read_number
    when '+'
      advance
      Token.new(:plus)
    when '-'
      advance
      Token.new(:minus)
    when '*'
      advance
      Token.new(:asterisk)
    when '/'
      advance
      Token.new(:slash)
    when '('
      advance
      Token.new(:l_paren)
    when ')'
      advance
      Token.new(:r_paren)
    else
      raise "Unknown character #{current_char}"
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

  def eol?
    @index >= @input.size
  end
end

__END__
'+' → type :plus, value=nil
'-' → type :minus, value = nil


1 → :int, value = 1
文の終わり
   :eol, value = nil

1      + 2


0123456789
123 + 345 + 3

Token.new(:int,input[6..8])

0123456789
1 + 2 + 3

6を読む→+とわかる→インデックスを1増やす
index = 7
input.size = 8

index + 1 == input.size
