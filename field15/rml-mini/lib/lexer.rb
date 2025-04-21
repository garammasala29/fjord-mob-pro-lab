class Lexer
  def self.tokenize(expr)
    # step1用の Lexer
    # この実装では後々困るので、アップデートする必要がある
    tokens = expr.strip.split
    lhs = tokens[0].to_i
    op = tokens[1]
    rhs = tokens[2].to_i

    [lhs, op, rhs]
  end
end
