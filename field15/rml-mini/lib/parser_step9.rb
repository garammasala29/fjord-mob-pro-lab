require_relative 'lexer'
require_relative 'node'

class ParserStep9
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
    elsif @current_token.type == :while
      while_statement
    elsif @current_token.type == :identifier && peek_next_token.type == :equals
      var_name = @current_token.value
      consume(:identifier)
      consume(:equals)
      value = comparison
      Node::Assignment.new(var_name, value)
    elsif @current_token.type == :hyouji
      hyouji_statement
    elsif @current_token.type == :func
      function_def
    elsif @current_token.type == :return
      return_statement
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

  def while_statement
    consume(:while)
    condition = with_delimiters(type: :angle) { comparison }
    body = with_delimiters(type: :brace) { statements }

    Node::WhileStatement.new(
      condition,
      body
    )
  end

  def hyouji_statement
    consume(:hyouji)
    expression = with_delimiters(type: :paren) { comparison }

    Node::HyoujiStatement.new(expression)
  end

  def function_def
    consume(:func)
    function_name = @current_token.value
    consume(:identifier)
    params = with_delimiters(type: :paren) { parameter_list }
    body = with_delimiters(type: :brace) { statements }

    Node::FunctionDef.new(function_name, params, body)
  end

  def return_statement
    consume(:return)
    expression = statement_end_token? ? nil : comparison
    Node::ReturnStatement.new(expression)
  end

  def statement_end_token?
    %i[r_brace eol].include?(@current_token.type)
  end

  def parameter_list
    return [] if @current_token.type == :r_paren

    result = []
    result << @current_token.value
    consume(:identifier)

    while @current_token.type == :comma
      consume(:comma)
      result << @current_token.value
      consume(:identifier)
    end
    result
  end

  def argument_list
    return [] if @current_token.type == :r_paren

    result = []
    result << comparison

    while @current_token.type == :comma
      consume(:comma)
      result << comparison
    end
    result
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

      if @current_token.type == :l_paren
        arguments = with_delimiters(type: :paren) { argument_list }
        node = Node::FunctionCall.new(value, arguments)
      else
        node = Node::Variable.new(value)
      end
    elsif @current_token.type == :true
      consume(:true)
      node = Node::Boolean.new(true)
    elsif @current_token.type == :false
      consume(:false)
      node = Node::Boolean.new(false)
    elsif @current_token.type == :string
      value = @current_token.value
      consume(:string)
      node = Node::String.new(value)
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
