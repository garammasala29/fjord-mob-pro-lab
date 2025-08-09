require_relative 'lexer'
require_relative 'node'

class ParserStep7
  # Data型の定義
  ConditionalBranch = Data.define(:condition, :body)

  # 各括弧タイプに対応する開始・終了トークンのマッピング
  DELIMITER_TOKENS = {
    paren: [:l_paren, :r_paren],
    brace: [:l_brace, :r_brace],
    angle: [:less, :greater],
  }.freeze

  COMPARISON_OPERATORS = %i[equal_equal not_equal less greater equal_less equal_greater].freeze

  # =============================================================================
  # 公開インターフェース
  # =============================================================================

  def self.parse(input)
    new(input).parse
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def parse
    result = statement

    if @current_token.type != :eol
      raise "Unexpected token: #{@current_token.value}"
    end

    result
  end

  private

  # =============================================================================
  # 主要文法解析メソッド（再帰下降パーサーの階層順）
  # =============================================================================

  def statement
    case @current_token.type
    when :if
      if_statement
    when :while
      while_statement
    when :identifier
      if peek_next_token.type == :equals # 変数代入
        var_name = @current_token.value
        consume(:identifier)
        consume(:equals)
        value = comparison

        Node::Assignment.new(var_name, value)
      else
        comparison
      end
    else
      comparison
    end
  end

  def comparison
    result = expr

    while comparison_operator?
      break if condition_end_token?

      op = @current_token.type
      consume(op)
      rhs = expr

      result = Node::ComparisonOp.new(result, op, rhs)
    end

    result
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
    case @current_token.type
    when :int
      value = @current_token.value
      consume(:int)

      Node::Integer.new(value)
    when :true, :false then boolean_literal
    when :identifier
      name = @current_token.value
      consume(:identifier)

      Node::Variable.new(name)
    when :l_paren then with_delimiters(type: :paren) { comparison } # かっこの中で比較演算使える
    else
      raise "Unexpected token: #{@current_token.value}"
    end
  end

  # =============================================================================
  # 特殊構文解析メソッド
  # =============================================================================

  def if_statement # if < condition > { } [else-if < elsif_condition > { elsif_body } else-if <> {} else {}]
    if_branch = parse_conditional_branch(keyword: :if, require_condition: true)

    else_ifs = []
    while @current_token.type == :else_if
      else_ifs << parse_conditional_branch(keyword: :else_if, require_condition: true)
    end

    else_body =
      if @current_token.type == :else
        parse_conditional_branch(keyword: :else, require_condition: false).body
      end

    Node::IfStatement.new(
      if_branch.condition,
      if_branch.body,
      else_ifs,
      else_body
    )
  end

  def while_statement # while < condition > { body }
    consume(:while)
    condition = with_delimiters(type: :angle) { comparison }
    body = with_delimiters(type: :brace) { statements }

    Node::WhileStatement.new(condition, body)
  end

  def statements
    statements = []

    # '}' or EOL まで statementを読む
    while @current_token.type != :r_brace && @current_token.type != :eol
      statements << statement
    end

    statements.size == 1 ? statements.first : Node::Block.new(statements)
  end

  def parse_conditional_branch(keyword:, require_condition: )
    consume(keyword)
    condition = with_delimiters(type: :angle) { comparison } if require_condition
    body = with_delimiters(type: :brace) { statements }

    ConditionalBranch.new(condition, body)
  end

  # =============================================================================
  # ヘルパーメソッド（パーサーの基本操作）
  # =============================================================================

  def consume(expected_type)
    if @current_token.type != expected_type
      raise "Expected #{expected_type}, got: #{@current_token.type}"
    end

    @current_token = @lexer.next_token
  end

  # 次のトークンを消費せずに確認するヘルパーメソッド
  def peek_next_token
    @lexer.peek_token
  end

  # =============================================================================
  # ユーティリティメソッド（判定・変換・抽象化）
  # =============================================================================

  def comparison_operator?
    COMPARISON_OPERATORS.include?(@current_token.type)
  end

  def condition_end_token? = @current_token.type == :greater && peek_next_token.type == :l_brace

  def boolean_literal
    val = @current_token.type
    consume(val)
    Node::Boolean.new(val == :true)
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
