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
    # 整数読み込んで左辺とする
    lhs = consume_int
    # 演算子かどうかチェックして、演算子である限り以下の処理を行う
      # 演算子を変数として保持
      # トークン1つ進める
      # 整数読み込んで右辺とする
      # 評価して左辺とする
    while %i[plus minus asterisk slash].include?(@current_token.type)
      op = @current_token
      advance
      rhs = consume_int
      lhs = evaluate(lhs, op, rhs)
    end
    lhs
  end

  private

  def consume_int
    # エラー処理
    raise "Unknown character" if @current_token.type != :int
    # カレントトークンの値を返す
    value = @current_token.value
    # 1つトークンを進める
    advance
    value
  end

  def advance
    #トークン1つ進める
    @current_token = @lexer.next_token
  end

  def evaluate(lhs, op, rhs)
    # 演算子によって実際に評価して返す
    case op.type
    when :plus
      lhs + rhs
    when :minus
      lhs - rhs
    when :asterisk
      lhs * rhs
    when :slash
      lhs / rhs
    else
      raise "Unknown operator: #{op.type}"
    end
  end
end


__END__
'3 + 4 * 5'
→ [
  <Token @type=int @value=3>, ← current_token
  <Token @type=:plus>,
  <Token @type=int @value=4>,
  <Token @type=:asterisk>,
  <Token @type=int @value=5>
]


ParserStep2.eval("2 + 3 * 4") #=> 20 (2 + 3 = 5, 5 * 4 = 20)
ParserStep2.eval("10 - 2 + 1") #=> 9
