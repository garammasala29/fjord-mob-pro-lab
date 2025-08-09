# spec/evaluator_step8_spec.rb
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

    # STEP8新機能: 文字列のテスト
    describe "string literals" do
      it "evaluates simple string" do
        node = Node::String.new("Hello World")
        expect(subject.evaluate(node)).to eq("Hello World")
      end

      it "evaluates empty string" do
        node = Node::String.new("")
        expect(subject.evaluate(node)).to eq("")
      end

      it "evaluates string with special characters" do
        node = Node::String.new("Hello\nWorld")
        expect(subject.evaluate(node)).to eq("Hello\nWorld")
      end

      it "evaluates string assignment" do
        assignment = Node::Assignment.new("message", Node::String.new("Hello"))
        expect(subject.evaluate(assignment)).to eq("Hello")

        variable = Node::Variable.new("message")
        expect(subject.evaluate(variable)).to eq("Hello")
      end
    end

    # STEP8新機能: 文字列連結のテスト
    describe "string concatenation" do
      it "concatenates two strings" do
        node = Node::BinaryOp.new(
          Node::String.new("Hello "),
          :plus,
          Node::String.new("World")
        )
        expect(subject.evaluate(node)).to eq("Hello World")
      end

      it "concatenates string and integer" do
        node = Node::BinaryOp.new(
          Node::String.new("Count: "),
          :plus,
          Node::Integer.new(42)
        )
        expect(subject.evaluate(node)).to eq("Count: 42")
      end

      it "concatenates integer and string" do
        node = Node::BinaryOp.new(
          Node::Integer.new(42),
          :plus,
          Node::String.new(" items")
        )
        expect(subject.evaluate(node)).to eq("42 items")
      end

      it "concatenates string and boolean" do
        node = Node::BinaryOp.new(
          Node::String.new("Value: "),
          :plus,
          Node::Boolean.new(true)
        )
        expect(subject.evaluate(node)).to eq("Value: true")

        node = Node::BinaryOp.new(
          Node::Boolean.new(false),
          :plus,
          Node::String.new(" result")
        )
        expect(subject.evaluate(node)).to eq("false result")
      end

      it "concatenates string and variable" do
        subject.evaluate(Node::Assignment.new("name", Node::String.new("Alice")))

        node = Node::BinaryOp.new(
          Node::String.new("Hello "),
          :plus,
          Node::Variable.new("name")
        )
        expect(subject.evaluate(node)).to eq("Hello Alice")
      end

      it "concatenates multiple strings (left-associative)" do
        # "a" + "b" + "c" should be evaluated as ("a" + "b") + "c"
        node = Node::BinaryOp.new(
          Node::BinaryOp.new(
            Node::String.new("a"),
            :plus,
            Node::String.new("b")
          ),
          :plus,
          Node::String.new("c")
        )
        expect(subject.evaluate(node)).to eq("abc")
      end

      it "concatenates mixed types in complex expression" do
        # "Result: " + (5 + 3) + " items"
        node = Node::BinaryOp.new(
          Node::BinaryOp.new(
            Node::String.new("Result: "),
            :plus,
            Node::BinaryOp.new(
              Node::Integer.new(5),
              :plus,
              Node::Integer.new(3)
            )
          ),
          :plus,
          Node::String.new(" items")
        )
        expect(subject.evaluate(node)).to eq("Result: 8 items")
      end

      it "concatenates nil value" do
        # nilとの連結もテスト
        subject.evaluate(Node::Assignment.new("empty_var", Node::Boolean.new(true)))
        # 変数を削除してnilにする（実際にはEnvironmentがnilを返すことはないが、テスト用）

        node = Node::BinaryOp.new(
          Node::String.new("Value: "),
          :plus,
          Node::String.new("")  # 空文字列で代用
        )
        expect(subject.evaluate(node)).to eq("Value: ")
      end

      it "still performs numeric addition when no strings involved" do
        # 文字列が関わらない場合は通常の数値加算
        node = Node::BinaryOp.new(
          Node::Integer.new(5),
          :plus,
          Node::Integer.new(3)
        )
        expect(subject.evaluate(node)).to eq(8)
      end
    end

    # STEP8新機能: hyouji文のテスト
    describe "hyouji statement" do
      it "outputs string and returns nil" do
        node = Node::HyoujiStatement.new(Node::String.new("Hello World"))

        expect { subject.evaluate(node) }.to output("Hello World\n").to_stdout
        expect(subject.evaluate(node)).to be_nil
      end

      it "outputs integer and returns nil" do
        node = Node::HyoujiStatement.new(Node::Integer.new(42))

        expect { subject.evaluate(node) }.to output("42\n").to_stdout
        expect(subject.evaluate(node)).to be_nil
      end

      it "outputs boolean and returns nil" do
        node = Node::HyoujiStatement.new(Node::Boolean.new(true))

        expect { subject.evaluate(node) }.to output("true\n").to_stdout
        expect(subject.evaluate(node)).to be_nil
      end

      it "outputs variable value" do
        subject.evaluate(Node::Assignment.new("message", Node::String.new("Hello")))
        node = Node::HyoujiStatement.new(Node::Variable.new("message"))

        expect { subject.evaluate(node) }.to output("Hello\n").to_stdout
      end

      it "outputs result of string concatenation" do
        subject.evaluate(Node::Assignment.new("name", Node::String.new("Alice")))

        concatenation = Node::BinaryOp.new(
          Node::String.new("Hello "),
          :plus,
          Node::Variable.new("name")
        )
        node = Node::HyoujiStatement.new(concatenation)

        expect { subject.evaluate(node) }.to output("Hello Alice\n").to_stdout
      end

      it "outputs result of arithmetic expression" do
        addition = Node::BinaryOp.new(
          Node::Integer.new(5),
          :plus,
          Node::Integer.new(3)
        )
        node = Node::HyoujiStatement.new(addition)

        expect { subject.evaluate(node) }.to output("8\n").to_stdout
      end

      it "outputs result of comparison expression" do
        comparison = Node::ComparisonOp.new(
          Node::Integer.new(5),
          :greater,
          Node::Integer.new(3)
        )
        node = Node::HyoujiStatement.new(comparison)

        expect { subject.evaluate(node) }.to output("true\n").to_stdout
      end

      it "outputs complex mixed expression" do
        # "Count: " + (5 + 3) + " > 5 is " + (8 > 5)
        complex_expr = Node::BinaryOp.new(
          Node::BinaryOp.new(
            Node::BinaryOp.new(
              Node::String.new("Count: "),
              :plus,
              Node::BinaryOp.new(Node::Integer.new(5), :plus, Node::Integer.new(3))
            ),
            :plus,
            Node::String.new(" > 5 is ")
          ),
          :plus,
          Node::ComparisonOp.new(Node::Integer.new(8), :greater, Node::Integer.new(5))
        )
        node = Node::HyoujiStatement.new(complex_expr)

        expect { subject.evaluate(node) }.to output("Count: 8 > 5 is true\n").to_stdout
      end
    end

    # 比較演算子のテスト（既存）
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

      it "compares strings" do
        node = Node::ComparisonOp.new(
          Node::String.new("hello"),
          :equal_equal,
          Node::String.new("hello")
        )
        expect(subject.evaluate(node)).to eq(true)

        node = Node::ComparisonOp.new(
          Node::String.new("hello"),
          :equal_equal,
          Node::String.new("world")
        )
        expect(subject.evaluate(node)).to eq(false)
      end

      it "compares string and number" do
        node = Node::ComparisonOp.new(
          Node::String.new("42"),
          :equal_equal,
          Node::Integer.new(42)
        )
        expect(subject.evaluate(node)).to eq(false) # 型が違うのでfalse
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

    # if文のテスト（文字列込み）
    describe "if statement with strings" do
      it "executes then branch with string condition" do
        # if < name == "Alice" > { result = "Hello Alice" }
        subject.evaluate(Node::Assignment.new("name", Node::String.new("Alice")))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("name"),
          :equal_equal,
          Node::String.new("Alice")
        )
        then_body = Node::Assignment.new("result", Node::String.new("Hello Alice"))
        if_node = Node::IfStatement.new(condition, then_body)

        expect(subject.evaluate(if_node)).to eq("Hello Alice")
        expect(subject.evaluate(Node::Variable.new("result"))).to eq("Hello Alice")
      end

      it "executes else branch with string" do
        condition = Node::ComparisonOp.new(
          Node::String.new("Alice"),
          :equal_equal,
          Node::String.new("Bob")
        )
        then_body = Node::Assignment.new("result", Node::String.new("Match"))
        else_body = Node::Assignment.new("result", Node::String.new("No match"))
        if_node = Node::IfStatement.new(condition, then_body, [], else_body)

        expect(subject.evaluate(if_node)).to eq("No match")
      end

      it "executes hyouji in if body" do
        condition = Node::Boolean.new(true)
        then_body = Node::HyoujiStatement.new(Node::String.new("Condition is true"))
        if_node = Node::IfStatement.new(condition, then_body)

        expect { subject.evaluate(if_node) }.to output("Condition is true\n").to_stdout
        expect(subject.evaluate(if_node)).to be_nil
      end
    end

    # while文のテスト（文字列込み）
    describe "while statement with strings" do
      it "executes while with hyouji in body" do
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("counter"),
          :less,
          Node::Integer.new(2)
        )

        body = Node::Block.new([
          Node::HyoujiStatement.new(
            Node::BinaryOp.new(
              Node::String.new("Count: "),
              :plus,
              Node::Variable.new("counter")
            )
          ),
          Node::Assignment.new(
            "counter",
            Node::BinaryOp.new(
              Node::Variable.new("counter"),
              :plus,
              Node::Integer.new(1)
            )
          )
        ])

        while_node = Node::WhileStatement.new(condition, body)

        expect { subject.evaluate(while_node) }.to output("Count: 0\nCount: 1\n").to_stdout
        expect(subject.evaluate(Node::Variable.new("counter"))).to eq(2)
      end

      it "executes while with string assignment" do
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))
        subject.evaluate(Node::Assignment.new("status", Node::String.new("starting")))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("counter"),
          :less,
          Node::Integer.new(2)
        )

        body = Node::Block.new([
          Node::Assignment.new("status", Node::String.new("processing")),
          Node::Assignment.new(
            "counter",
            Node::BinaryOp.new(
              Node::Variable.new("counter"),
              :plus,
              Node::Integer.new(1)
            )
          )
        ])

        while_node = Node::WhileStatement.new(condition, body)

        expect(subject.evaluate(while_node)).to eq(2)
        expect(subject.evaluate(Node::Variable.new("status"))).to eq("processing")
      end
    end

    # STEP8新機能: 統合テスト
    describe "step8 integration tests" do
      it "combines all features in complex scenario" do
        # name = "Alice"
        # age = 25
        # if < age => 18 > {
        #   greeting = "Hello " + name + ", you are " + age + " years old"
        #   hyouji(greeting)
        # } else {
        #   hyouji("Too young")
        # }

        subject.evaluate(Node::Assignment.new("name", Node::String.new("Alice")))
        subject.evaluate(Node::Assignment.new("age", Node::Integer.new(25)))

        condition = Node::ComparisonOp.new(
          Node::Variable.new("age"),
          :equal_greater,
          Node::Integer.new(18)
        )

        greeting_concat = Node::BinaryOp.new(
          Node::BinaryOp.new(
            Node::BinaryOp.new(
              Node::String.new("Hello "),
              :plus,
              Node::Variable.new("name")
            ),
            :plus,
            Node::String.new(", you are ")
          ),
          :plus,
          Node::BinaryOp.new(
            Node::Variable.new("age"),
            :plus,
            Node::String.new(" years old")
          )
        )

        then_body = Node::Block.new([
          Node::Assignment.new("greeting", greeting_concat),
          Node::HyoujiStatement.new(Node::Variable.new("greeting"))
        ])

        else_body = Node::HyoujiStatement.new(Node::String.new("Too young"))

        if_node = Node::IfStatement.new(condition, then_body, [], else_body)

        expect { subject.evaluate(if_node) }.to output("Hello Alice, you are 25 years old\n").to_stdout
        expect(subject.evaluate(Node::Variable.new("greeting"))).to eq("Hello Alice, you are 25 years old")
      end

      it "factorial with string output" do
        # factorial = 1, i = 1, n = 5
        # while < i =< n > {
        #   hyouji("Calculating " + i + "! factorial")
        #   factorial = factorial * i
        #   i = i + 1
        # }
        # hyouji("Result: " + factorial)

        subject.evaluate(Node::Assignment.new("factorial", Node::Integer.new(1)))
        subject.evaluate(Node::Assignment.new("i", Node::Integer.new(1)))
        subject.evaluate(Node::Assignment.new("n", Node::Integer.new(3))) # 小さい値でテスト

        condition = Node::ComparisonOp.new(
          Node::Variable.new("i"),
          :equal_less,
          Node::Variable.new("n")
        )

        body = Node::Block.new([
          Node::HyoujiStatement.new(
            Node::BinaryOp.new(
              Node::BinaryOp.new(
                Node::String.new("Calculating "),
                :plus,
                Node::Variable.new("i")
              ),
              :plus,
              Node::String.new("! factorial")
            )
          ),
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
        final_output = Node::HyoujiStatement.new(
          Node::BinaryOp.new(
            Node::String.new("Result: "),
            :plus,
            Node::Variable.new("factorial")
          )
        )

        expected_output = "Calculating 1! factorial\nCalculating 2! factorial\nCalculating 3! factorial\nResult: 6\n"

        expect {
          subject.evaluate(while_node)
          subject.evaluate(final_output)
        }.to output(expected_output).to_stdout

        expect(subject.evaluate(Node::Variable.new("factorial"))).to eq(6)
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
