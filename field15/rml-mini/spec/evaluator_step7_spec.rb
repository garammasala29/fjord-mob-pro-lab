# spec/evaluator_step7_spec.rb
require_relative "../lib/evaluator"
require_relative "../lib/node"

RSpec.describe Evaluator do
  subject { described_class.new }

  def mock_conditional_branch(condition:, body:)
    double("conditional_branch", condition: condition, body: body)
  end

  describe "#evaluate" do
    # Step4からの継承テスト
    it "evaluates integer node" do
      node = Node::Integer.new(42)
      expect(subject.evaluate(node)).to eq(42)
    end

    it "evaluates addition" do
      node = Node::BinaryOp.new(
        Node::Integer.new(1),
        :plus,
        Node::Integer.new(2)
      )
      expect(subject.evaluate(node)).to eq(3)
    end

    it "evaluates subtraction" do
      node = Node::BinaryOp.new(
        Node::Integer.new(5),
        :minus,
        Node::Integer.new(3)
      )
      expect(subject.evaluate(node)).to eq(2)
    end

    it "evaluates multiplication" do
      node = Node::BinaryOp.new(
        Node::Integer.new(3),
        :asterisk,
        Node::Integer.new(4)
      )
      expect(subject.evaluate(node)).to eq(12)
    end

    it "evaluates division" do
      node = Node::BinaryOp.new(
        Node::Integer.new(10),
        :slash,
        Node::Integer.new(2)
      )
      expect(subject.evaluate(node)).to eq(5)
    end

    it "evaluates nested operations" do
      # (2 + 3) * 4
      node = Node::BinaryOp.new(
        Node::BinaryOp.new(
          Node::Integer.new(2),
          :plus,
          Node::Integer.new(3)
        ),
        :asterisk,
        Node::Integer.new(4)
      )
      expect(subject.evaluate(node)).to eq(20)
    end

    # Step5からの継承テスト（Variable, Assignment）
    it "evaluates variable assignment and reference" do
      assignment = Node::Assignment.new("x", Node::Integer.new(42))
      expect(subject.evaluate(assignment)).to eq(42)

      variable = Node::Variable.new("x")
      expect(subject.evaluate(variable)).to eq(42)
    end

    it "raises error for undefined variable" do
      node = Node::Variable.new("undefined_var")
      expect { subject.evaluate(node) }.to raise_error(/未定義の変数/)
    end

    # Boolean型のテスト
    it "evaluates boolean true" do
      node = Node::Boolean.new(true)
      expect(subject.evaluate(node)).to eq(true)
    end

    it "evaluates boolean false" do
      node = Node::Boolean.new(false)
      expect(subject.evaluate(node)).to eq(false)
    end

    # 比較演算子のテスト
    describe "comparison operations" do
      it "evaluates equality ==" do
        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :equal_equal,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :equal_equal,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(false)
      end

      it "evaluates inequality !=" do
        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :not_equal,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :not_equal,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(false)
      end

      it "evaluates less than <" do
        node = Node::ComparisonOp.new(
          Node::Integer.new(3),
          :less,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :less,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(false)
      end

      it "evaluates greater than >" do
        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :greater,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(3),
          :greater,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(false)
      end

      it "evaluates less than or equal =< (custom syntax)" do
        node = Node::ComparisonOp.new(
          Node::Integer.new(3),
          :equal_less,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :equal_less,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :equal_less,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(false)
      end

      it "evaluates greater than or equal => (custom syntax)" do
        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :equal_greater,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :equal_greater,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::Integer.new(3),
          :equal_greater,
          Node::Integer.new(5)
        )
        expect(subject.evaluate(node)).to eq(false)
      end
    end

    # if文のテスト
    describe "if statement" do
      it "executes then branch when condition is true" do
        then_body = Node::Assignment.new("result", Node::Integer.new(42))
        if_node = Node::IfStatement.new(Node::Boolean.new(true), then_body)

        expect(subject.evaluate(if_node)).to eq(42)

        # 変数が設定されていることを確認
        var_node = Node::Variable.new("result")
        expect(subject.evaluate(var_node)).to eq(42)
      end

      it "returns nil when condition is false and no else" do
        then_body = Node::Assignment.new("result", Node::Integer.new(42))
        if_node = Node::IfStatement.new(Node::Boolean.new(false), then_body)

        expect(subject.evaluate(if_node)).to be_nil
      end

      it "executes else branch when condition is false" do
        then_body = Node::Assignment.new("result", Node::Integer.new(42))
        else_body = Node::Assignment.new("result", Node::Integer.new(24))
        if_node = Node::IfStatement.new(Node::Boolean.new(false), then_body, [], else_body)

        expect(subject.evaluate(if_node)).to eq(24)

        var_node = Node::Variable.new("result")
        expect(subject.evaluate(var_node)).to eq(24)
      end

      it "executes else-if branch" do
        then_body = Node::Assignment.new("result", Node::Integer.new(1))
        elsif_body = Node::Assignment.new("result", Node::Integer.new(2))
        else_body = Node::Assignment.new("result", Node::Integer.new(3))

        else_ifs = [
          mock_conditional_branch(condition: Node::Boolean.new(true), body: elsif_body)
        ]

        if_node = Node::IfStatement.new(Node::Boolean.new(false), then_body, else_ifs, else_body)

        expect(subject.evaluate(if_node)).to eq(2)

        var_node = Node::Variable.new("result")
        expect(subject.evaluate(var_node)).to eq(2)
      end

      it "executes multiple statements in block" do
        statements = [
          Node::Assignment.new("x", Node::Integer.new(10)),
          Node::Assignment.new("y", Node::Integer.new(20))
        ]
        block = Node::Block.new(statements)
        if_node = Node::IfStatement.new(Node::Boolean.new(true), block)

        expect(subject.evaluate(if_node)).to eq(20) # 最後のstatementの結果

        # 両方の変数が設定されていることを確認
        expect(subject.evaluate(Node::Variable.new("x"))).to eq(10)
        expect(subject.evaluate(Node::Variable.new("y"))).to eq(20)
      end

      it "handles complex else-if chain" do
        then_body = Node::Assignment.new("grade", Node::Integer.new(1))
        else_body = Node::Assignment.new("grade", Node::Integer.new(4))

        else_ifs = [
          mock_conditional_branch(condition: Node::Boolean.new(false), body: Node::Assignment.new("grade", Node::Integer.new(2))),
          mock_conditional_branch(condition: Node::Boolean.new(true), body: Node::Assignment.new("grade", Node::Integer.new(3)))
        ]

        if_node = Node::IfStatement.new(
          Node::Boolean.new(false),
          then_body,
          else_ifs,
          else_body
        )

        expect(subject.evaluate(if_node)).to eq(3)
        expect(subject.evaluate(Node::Variable.new("grade"))).to eq(3)
      end

      it "raises error when condition is not boolean" do
        then_body = Node::Assignment.new("result", Node::Integer.new(42))
        if_node = Node::IfStatement.new(Node::Integer.new(42), then_body)

        expect { subject.evaluate(if_node) }.to raise_error(/The condition of an if statement must be a boolean/)
      end

      it "raises error when else-if condition is not boolean" do
        then_body = Node::Assignment.new("result", Node::Integer.new(1))
        elsif_body = Node::Assignment.new("result", Node::Integer.new(2))

        else_ifs = [
          mock_conditional_branch(condition: Node::Integer.new(42), body: elsif_body)
        ]
        if_node = Node::IfStatement.new(Node::Boolean.new(false), then_body, else_ifs)

        expect { subject.evaluate(if_node) }.to raise_error(/The condition of an else-if statement must be a boolean/)
      end
    end

    # STEP7新機能: while文のテスト
    describe "while statement" do
      it "executes body while condition is true" do
        # counter = 0, while < counter < 3 > { counter = counter + 1 }
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("counter"),
          :less,
          Node::Integer.new(3)
        )
        body = Node::Assignment.new(
          "counter",
          Node::BinaryOp.new(
            Node::Variable.new("counter"),
            :plus,
            Node::Integer.new(1)
          )
        )
        while_node = Node::WhileStatement.new(condition, body)

        expect(subject.evaluate(while_node)).to eq(3)
        expect(subject.evaluate(Node::Variable.new("counter"))).to eq(3)
      end

      it "returns nil when condition is false initially" do
        condition = Node::Boolean.new(false)
        body = Node::Assignment.new("x", Node::Integer.new(42))
        while_node = Node::WhileStatement.new(condition, body)

        expect(subject.evaluate(while_node)).to be_nil
      end

      it "executes factorial calculation" do
        # factorial = 1, i = 1, n = 5
        # while < i =< n > { factorial = factorial * i, i = i + 1 }
        subject.evaluate(Node::Assignment.new("factorial", Node::Integer.new(1)))
        subject.evaluate(Node::Assignment.new("i", Node::Integer.new(1)))
        subject.evaluate(Node::Assignment.new("n", Node::Integer.new(5)))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("i"),
          :equal_less,
          Node::Variable.new("n")
        )
        body = Node::Block.new([
          Node::Assignment.new(
            "factorial",
            Node::BinaryOp.new(
              Node::Variable.new("factorial"),
              :asterisk,
              Node::Variable.new("i")
            )
          ),
          Node::Assignment.new(
            "i",
            Node::BinaryOp.new(
              Node::Variable.new("i"),
              :plus,
              Node::Integer.new(1)
            )
          )
        ])
        while_node = Node::WhileStatement.new(condition, body)

        expect(subject.evaluate(while_node)).to eq(6) # 最後の i = i + 1 の結果
        expect(subject.evaluate(Node::Variable.new("factorial"))).to eq(120) # 5!
        expect(subject.evaluate(Node::Variable.new("i"))).to eq(6)
      end

      it "handles complex condition" do
        # x = 10, y = 5
        # while < (x + y) > 10 > { x = x - 1 }
        subject.evaluate(Node::Assignment.new("x", Node::Integer.new(10)))
        subject.evaluate(Node::Assignment.new("y", Node::Integer.new(5)))

        condition = Node::ComparisonOp.new(
          Node::BinaryOp.new(
            Node::Variable.new("x"),
            :plus,
            Node::Variable.new("y")
          ),
          :greater,
          Node::Integer.new(10)
        )
        body = Node::Assignment.new(
          "x",
          Node::BinaryOp.new(
            Node::Variable.new("x"),
            :minus,
            Node::Integer.new(1)
          )
        )
        while_node = Node::WhileStatement.new(condition, body)

        expect(subject.evaluate(while_node)).to eq(5) # 最後の x = x - 1 の結果
        expect(subject.evaluate(Node::Variable.new("x"))).to eq(5)
        expect(subject.evaluate(Node::Variable.new("y"))).to eq(5)
      end

      it "executes while with boolean variable condition" do
        subject.evaluate(Node::Assignment.new("running", Node::Boolean.new(true)))
        subject.evaluate(Node::Assignment.new("count", Node::Integer.new(0)))

        condition = Node::Variable.new("running")
        body = Node::Block.new([
          Node::Assignment.new(
            "count",
            Node::BinaryOp.new(
              Node::Variable.new("count"),
              :plus,
              Node::Integer.new(1)
            )
          ),
          Node::Assignment.new(
            "running",
            Node::ComparisonOp.new(
              Node::Variable.new("count"),
              :less,
              Node::Integer.new(3)
            )
          )
        ])
        while_node = Node::WhileStatement.new(condition, body)

        result = subject.evaluate(while_node)
        expect(result).to eq(false) # 最後の running = false の結果
        expect(subject.evaluate(Node::Variable.new("count"))).to eq(3)
        expect(subject.evaluate(Node::Variable.new("running"))).to eq(false)
      end

      it "handles nested while loops" do
        # outer = 2, inner = 2, sum = 0
        # while < outer > 0 > {
        #   inner = 2
        #   while < inner > 0 > { sum = sum + 1, inner = inner - 1 }
        #   outer = outer - 1
        # }
        subject.evaluate(Node::Assignment.new("outer", Node::Integer.new(2)))
        subject.evaluate(Node::Assignment.new("sum", Node::Integer.new(0)))

        inner_condition = Node::ComparisonOp.new(
          Node::Variable.new("inner"),
          :greater,
          Node::Integer.new(0)
        )
        inner_body = Node::Block.new([
          Node::Assignment.new(
            "sum",
            Node::BinaryOp.new(
              Node::Variable.new("sum"),
              :plus,
              Node::Integer.new(1)
            )
          ),
          Node::Assignment.new(
            "inner",
            Node::BinaryOp.new(
              Node::Variable.new("inner"),
              :minus,
              Node::Integer.new(1)
            )
          )
        ])
        inner_while = Node::WhileStatement.new(inner_condition, inner_body)

        outer_condition = Node::ComparisonOp.new(
          Node::Variable.new("outer"),
          :greater,
          Node::Integer.new(0)
        )
        outer_body = Node::Block.new([
          Node::Assignment.new("inner", Node::Integer.new(2)),
          inner_while,
          Node::Assignment.new(
            "outer",
            Node::BinaryOp.new(
              Node::Variable.new("outer"),
              :minus,
              Node::Integer.new(1)
            )
          )
        ])
        outer_while = Node::WhileStatement.new(outer_condition, outer_body)

        expect(subject.evaluate(outer_while)).to eq(0) # 最後の outer = outer - 1 の結果
        expect(subject.evaluate(Node::Variable.new("sum"))).to eq(4) # 2 * 2 = 4
        expect(subject.evaluate(Node::Variable.new("outer"))).to eq(0)
      end

      it "raises error when condition is not boolean" do
        condition = Node::Integer.new(42)
        body = Node::Assignment.new("x", Node::Integer.new(1))
        while_node = Node::WhileStatement.new(condition, body)

        expect { subject.evaluate(while_node) }.to raise_error(/The condition of a while statement must be a boolean/)
      end

      it "prevents infinite loops with iteration limit" do
        condition = Node::Boolean.new(true)
        body = Node::Assignment.new("x", Node::Integer.new(1))
        while_node = Node::WhileStatement.new(condition, body)

        expect { subject.evaluate(while_node) }.to raise_error(/Loop exceeded maximum iterations.*Possible infinite loop detected/)
      end

      it "executes exactly at iteration limit" do
        # カウンタを使って正確に上限-1まで実行
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))
        subject.evaluate(Node::Assignment.new("limit", Node::Integer.new(9998)))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("counter"),
          :equal_less,
          Node::Variable.new("limit")
        )
        body = Node::Assignment.new(
          "counter",
          Node::BinaryOp.new(
            Node::Variable.new("counter"),
            :plus,
            Node::Integer.new(1)
          )
        )
        while_node = Node::WhileStatement.new(condition, body)

        # 9999回実行されるはず（0から9998まで）
        expect(subject.evaluate(while_node)).to eq(9999)
        expect(subject.evaluate(Node::Variable.new("counter"))).to eq(9999)
      end

      it "raises error when exceeding iteration limit by one" do
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))
        subject.evaluate(Node::Assignment.new("limit", Node::Integer.new(9999)))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("counter"),
          :equal_less,
          Node::Variable.new("limit")
        )
        body = Node::Assignment.new(
          "counter",
          Node::BinaryOp.new(
            Node::Variable.new("counter"),
            :plus,
            Node::Integer.new(1)
          )
        )
        while_node = Node::WhileStatement.new(condition, body)

        # 10000回実行しようとして上限（10000）を超える
        expect { subject.evaluate(while_node) }.to raise_error(/Loop exceeded maximum iterations/)
      end
    end

    # エラーケース
    it "raises error for unknown binary operator" do
      node = Node::BinaryOp.new(
        Node::Integer.new(1),
        :unknown,
        Node::Integer.new(2)
      )
      expect { subject.evaluate(node) }.to raise_error("Unknown operator: unknown")
    end

    it "raises error for unknown comparison operator" do
      node = Node::ComparisonOp.new(
        Node::Integer.new(1),
        :unknown_comparison,
        Node::Integer.new(2)
      )
      expect { subject.evaluate(node) }.to raise_error("Unknown comparison operator: unknown_comparison")
    end

    it "raises error for unknown node type" do
      # 存在しないノードタイプをテスト
      class UnknownNode; end
      node = UnknownNode.new

      expect { subject.evaluate(node) }.to raise_error(/Unknown node type/)
    end
  end
end
