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
    when /[a-zA-Z_]/ then read_identifier_or_keyword
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
    when '{'
      advance
      Token.new(:l_brace)
    when '}'
      advance
      Token.new(:r_brace)
    when '<'
      advance
      Token.new(:less)
    when '>'
      advance
      Token.new(:greater)
    when "="
      if peek_char == '='
        advance
        advance
        Token.new(:equal_equal)
      elsif peek_char == '<'
        advance
        advance
        Token.new(:equal_less)
      elsif peek_char == '>'
        advance
        advance
        Token.new(:equal_greater)
      else
        advance
        Token.new(:equals)
      end
    when '!'
      if peek_char == '='
        2.times { advance }
        Token.new(:not_equal)
      else
        raise "Unknown character #{current_char}"
      end
    else
      raise "Unknown character #{current_char}"
    end
  end

  def peek_token
    index = @index
    token = next_token
    @index = index

    token
  end

  private

  def skip_whitespace
    advance while current_char&.match?(/\s/)
  end

  def current_char
    @input[@index]
  end

  def peek_char
    @input[@index + 1]
  end

  def advance
    @index += 1
  end

  def read_number
    start_index = @index
    advance while current_char&.match?(/\d/)

    Token.new(:int, @input[start_index...@index].to_i)
  end

  def read_identifier_or_keyword
    start_index = @index
    advance while current_char&.match?(/[\w-]/)

    text = @input[start_index...@index]
    case text
    when 'true'
      Token.new(:true)
    when 'false'
      Token.new(:false)
    when 'if'
      Token.new(:if)
    when 'else-if'
      Token.new(:else_if)
    when 'else'
      Token.new(:else)
    else
      Token.new(:identifier, text)
    end
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
