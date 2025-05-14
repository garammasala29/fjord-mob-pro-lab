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

    def evaluate
      value
    end
  end

  class BinaryOp < Base
    attr_reader :left, :right, :op

    def initialize(left, op, right)
      @left = left
      @op = op
      @right = right
    end
  end
end
