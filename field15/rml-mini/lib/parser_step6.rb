require_relative 'lexer'
require_relative 'node'

class ParserStep6
  def self.parse(input)
    new(input).parse
  end

  def initialize(input)
    @lexer = Lexer.new(input)
    @current_token = @lexer.next_token
  end

  def parse
    # :TODO: 式から始めていたのを変える
    result = statement
    # エラー処理
    if @current_token.type != :eol
      raise "Unexpected token: #{@current_token.value}"
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
      value = expr
      Node::Assignment.new(var_name, value)
    else
      expr
    end
  end

  def if_statement
    consume(:if)
    consume(:less)
    condition = comparison
    consume(:greater)
    consume(:l_brace)
    then_body = statements
    consume(:r_brace)

    else_ifs = []
    while @current_token.type == :else_if
      consume(:else_if)
      consume(:less)
      elseif_condition = comparison
      consume(:greater)
      consume(:l_brace)
      elseif_body = statements
      consume(:r_brace)

      else_ifs << { condition: elseif_condition, body: elseif_body }
    end

    else_body = if @current_token.type == :else
                  consume(:else)
                  consume(:l_brace)
                  result = statements
                  consume(:r_brace)

                  result
                end

    Node::IfStatement.new(condition, then_body, else_ifs, else_body)
  end

  def comparison
    # todo
  end

  def statements
    # todo
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
      consume(:l_paren)
      node = expr
      consume(:r_paren)
    elsif @current_token.type == :identifier
      value = @current_token.value
      consume(:identifier)
      node = Node::Variable.new(value)
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
end
