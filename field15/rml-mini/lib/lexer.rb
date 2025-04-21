class Lexer
  def self.tokenize(text)
    # step1用の Lexer
    # この実装では後々困るので、アップデートする必要がある
    tokens = expr.strip.split
    left = tokens[0].to_i
    op = tokens[1]
    right = tokens[2].to_i

    [left, op, right]
  end
end
