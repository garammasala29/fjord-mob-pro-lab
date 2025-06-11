module Node
  class Integer
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

  class Assignment
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end
  end

  class Variable
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end
