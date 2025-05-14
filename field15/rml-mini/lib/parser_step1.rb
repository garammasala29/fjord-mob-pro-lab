require_relative 'lexer'

module ParserStep1
  def self.eval(expr)
    tokens = Lexer.tokenize(expr)
    # TODO: ここに実装を書く
    # opによって条件分岐する
    # "+"がきたら　〜
    # "-"がきたら ~
    # "*" がきたら ~
    # "/" がきたら ~
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
