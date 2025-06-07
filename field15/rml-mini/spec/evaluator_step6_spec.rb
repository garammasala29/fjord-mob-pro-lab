# spec/evaluator_step6_spec.rb
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

    # Step6新機能: Boolean型
    it "evaluates boolean true" do
      node = Node::Boolean.new(true)
      expect(subject.evaluate(node)).to eq(true)
    end

    it "evaluates boolean false" do
      node = Node::Boolean.new(false)
      expect(subject.evaluate(node)).to eq(false)
    end

    # Step6新機能: 比較演算子
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

    # Step6新機能: if文
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
