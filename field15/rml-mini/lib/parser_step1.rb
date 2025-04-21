require_relative 'lexer'

module ParserStep1
  def self.eval(expr)
    tokens = Lexer.tokenize(expr)
    # TODO: ここに実装を書く
  end
end
