module Node
  class Base
    def evaluate
      raise NotImplementedError, "#{self.class}#evaluate not implemented"
    end
  end

  class Integer < Base
    attr_reader :value

    def initialize(value)
      @value = value
    end
  end

  class BinaryOp < Base
    attr_reader :lhs, :rhs, :op

    def initialize(lhs, op, rhs)
      @lhs = lhs
      @op = op
      @rhs = rhs
    end
  end
end
