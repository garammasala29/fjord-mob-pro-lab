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
    # TODO: ここから実装する
  end
end
