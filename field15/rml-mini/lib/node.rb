module Node
  class Integer
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class Boolean
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class BinaryOp
    attr_reader :lhs, :rhs, :op

    def initialize(lhs, op, rhs)
      @lhs = lhs
      @op = op
      @rhs = rhs
    end
  end

  class ComparisonOp
    attr_reader :lhs, :rhs, :op

    def initialize(lhs, op, rhs)
      @lhs = lhs
      @op = op
      @rhs = rhs
    end
  end

  class Variable
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class Assignment
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end
  end

  class IfStatement
    attr_reader :condition, :then_body, :else_ifs, :else_body

    def initialize(condition, then_body, else_ifs = [], else_body = nil)
      @condition = condition
      @then_body = then_body # 配列 or statement
      @else_ifs = else_ifs # [{condition: node, body: [statements]}] の配列
      @else_body = else_body # 配列 or statement (optional)
    end
  end

  class Block
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end
  end
end
