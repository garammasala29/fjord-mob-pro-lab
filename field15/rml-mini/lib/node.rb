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
end
