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

    def evaluate
      lhs = left.evaluate
      rhs = right.evaluate

      case op
      when :plus then lhs + rhs
      when :minus then lhs - rhs
      when :asterisk then lhs * rhs
      when :slash then lhs / rhs
      else
        raise "Unknown operator: #{op}"
      end
    end
  end
end
