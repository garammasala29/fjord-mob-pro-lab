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
    result = expr

    if @current_token.type != :eol
      raise "Unexpected token: #{@current_token.value}"
    end

    result
  end

  private
  # 式
  def expr
    # termを読んで、左辺とする
    lhs = term

    while %i[plus minus].include?(@current_token.type)
      # 現在のトークンから演算子を読み込んで変数で保持
      op = @current_token
      # 演算子を消費する
      advance(op.type)
      # term　を呼んで右辺とする
      rhs = term
      # 演算子を見て、処理する
      case op.type
      when :plus
        lhs += rhs
      when :minus
        lhs -= rhs
      end
    end
    lhs
  end

  # 項 (n * m)　とかのこと
  def term
    # factorを呼んで左辺とする
    lhs = factor
    # * or / の演算子がある限り、処理
    while %i[asterisk slash].include?(@current_token.type)
      # 現在のトークンから演算子を読み込んで変数で保持
      op = @current_token
      # 演算子を消費する
      advance(op.type)
      # factor　を呼んで右辺とする
      rhs = factor
      # 演算子を見て、処理する
      case op.type
      when :asterisk
        lhs *= rhs
      when :slash
        lhs /= rhs
      end
    end
    lhs
  end

  # 因数 掛け算の片割れ
  def factor
    # intかどうか確認してエラー処理
    raise "Unexpected token: #{@current_token.value}" unless @current_token.type == :int
    # 値を取得
    value = @current_token.value
    # intをconsume
    advance(:int)

    # 値を戻り値として返す
    value
  end

  # 引数で与えられたタイプのトークンを消費(トークンを1つ進める)　advance
  def advance(expected_type)
    # 引数と現在のトークンがあってなかったらエラー
    raise "Unexpected token: #{@current_token.value}" unless @current_token.type == expected_type
    # カレントトークンに次のトークンを入れる
    @current_token = @lexer.next_token
  end
end
