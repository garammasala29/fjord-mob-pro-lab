# STEP2(このステップではlexerも自分で考えて実装しよう`lexer.rb`)
require_relative 'lexer'

class ParserStep2
  def self.eval(input)
    new(input).eval
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def eval
    # TODO: ここに実装を書く
  end
end
