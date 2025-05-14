require_relative 'lexer'

module ParserStep1
  def self.eval(expr)
    tokens = Lexer.tokenize(expr)

    lhs, op, rhs = tokens
    case op
    when '+'
      lhs + rhs
    when '-'
      lhs - rhs
    when '*'
      lhs * rhs
    when '/'
      lhs / rhs
    else
      raise "Unknown operator: #{op}"
    end
  end
end
