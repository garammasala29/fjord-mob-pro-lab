require_relative 'lexer'
require_relative 'node'

class ParserStep6
  ConditionalBranch = Data.define(:condition, :body)

  # 各括弧のタイプに対応する開始・終了トークンのマッピング
  DELIMITER_TOKENS = {
    paren: [:l_paren, :r_paren], # ()
    brace: [:l_brace, :r_brace], # {}
    angle: [:less, :greater] # <>
  }

  def self.parse(input)
    new(input).parse
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def parse
    result = statement

    # エラー処理
    if @current_token.type != :eol
      raise "Unexpected token: #{@current_token.inspect}"
    end

    result
  end

  private

  def statement
    if @current_token.type == :if
      if_statement
    elsif @current_token.type == :identifier && peek_next_token.type == :equals
      var_name = @current_token.value
      consume(:identifier)
      consume(:equals)
      value = comparison
      Node::Assignment.new(var_name, value)
    else
      comparison
    end
  end

  def if_statement
    if_branch = parse_conditional_branch(:if)

    else_ifs = []
    else_ifs << parse_conditional_branch(:else_if) while @current_token.type == :else_if

    else_body = parse_conditional_branch(:else).body if @current_token.type == :else

    Node::IfStatement.new(
      if_branch.condition,
      if_branch.body,
      else_ifs,
      else_body
    )
  end

  def comparison
    result = expr

    while %i[equal_equal not_equal less greater equal_less equal_greater].include?(@current_token.type)
      # op を取得
      op = @current_token.type
      break if op == :greater && peek_next_token.type == :l_brace

      consume(op)
      # 右辺を評価してrhsに入れる
      rhs = expr
      # Nodeに詰める
      result = Node::ComparisonOp.new(result, op, rhs)
    end

    result
  end

  def statements
    statements = []

    until @current_token.type == :r_brace || @current_token.type == :eol
    # until @current_token.type == :r_brace && peek_next_token.type == :eol
      statements << statement
    end

    statements.size == 1 ? statements.first : Node::Block.new(statements)
  end

  def expr
    result = term

    while %i[plus minus].include?(@current_token.type)
      op = @current_token.type
      consume(op)
      rhs = term

      result = Node::BinaryOp.new(result, op, rhs)
    end

    result
  end

  def term
    result = factor

    while %i[asterisk slash].include?(@current_token.type)
      op = @current_token.type
      consume(op)
      rhs = factor

      result = Node::BinaryOp.new(result, op, rhs)
    end

    result
  end

  def factor
    node = nil
    if @current_token.type == :int
      node = Node::Integer.new(@current_token.value)
      consume(:int)
    elsif @current_token.type == :l_paren
      node = with_delimiters(type: :paren) { comparison }
    elsif @current_token.type == :identifier
      value = @current_token.value
      consume(:identifier)
      node = Node::Variable.new(value)
    elsif @current_token.type == :true
      consume(:true)
      node = Node::Boolean.new(true)
    elsif @current_token.type == :false
      consume(:false)
      node = Node::Boolean.new(false)
    else
      raise "Unexpected token: #{@current_token.inspect}"
    end
    node
  end

  # 次のトークンを消費せずに確認するヘルパーメソッド
  def peek_next_token
    @lexer.peek_token
  end

  def consume(expected_type)
    if @current_token.type != expected_type
      raise "Expected #{expected_type}, got: #{@current_token.type}"
    end

    @current_token = @lexer.next_token
  end

  def parse_conditional_branch(keyword)
    consume(keyword)
    condition = with_delimiters(type: :angle) { comparison } if %i[if else_if].include?(keyword)
    body = with_delimiters(type: :brace) { statements }

    ConditionalBranch.new(condition, body)
  end

  def with_delimiters(type: :paren)
    left, right = DELIMITER_TOKENS.fetch(type) do
      raise "Unknown delimiter type: #{type}"
    end

    consume(left)
    result = yield
    consume(right)

    result
  end
end
