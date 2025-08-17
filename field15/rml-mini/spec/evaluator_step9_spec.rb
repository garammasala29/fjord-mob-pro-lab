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

    # STEP9新機能: 関数定義のテスト
    describe "function definitions" do
      it "evaluates function definition and returns function name" do
        func_def = Node::FunctionDef.new(
          "test",
          [],
          Node::ReturnStatement.new(Node::Integer.new(42))
        )

        result = subject.evaluate(func_def)
        expect(result).to eq("test")
      end

      it "registers function in environment" do
        func_def = Node::FunctionDef.new(
          "add",
          ["a", "b"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("a"),
              :plus,
              Node::Variable.new("b")
            )
          )
        )

        subject.evaluate(func_def)

        # 関数が環境に登録されていることを確認
        env = subject.instance_variable_get(:@environment)
        expect(env.function_exists?("add")).to be true
        expect(env.lookup_function("add")).to eq(func_def)
      end

      it "handles function with question mark in name" do
        func_def = Node::FunctionDef.new(
          "even?",
          ["n"],
          Node::ReturnStatement.new(
            Node::ComparisonOp.new(
              Node::BinaryOp.new(
                Node::BinaryOp.new(
                  Node::Variable.new("n"),
                  :slash,
                  Node::Integer.new(2)
                ),
                :asterisk,
                Node::Integer.new(2)
              ),
              :equal_equal,
              Node::Variable.new("n")
            )
          )
        )

        result = subject.evaluate(func_def)
        expect(result).to eq("even?")
      end

      it "handles function with exclamation mark in name" do
        func_def = Node::FunctionDef.new(
          "reset!",
          [],
          Node::Assignment.new("counter", Node::Integer.new(0))
        )

        result = subject.evaluate(func_def)
        expect(result).to eq("reset!")
      end
    end

    # STEP9新機能: 関数呼び出しのテスト
    describe "function calls" do
      it "calls function without parameters" do
        # 関数定義: func test() { return 42 }
        func_def = Node::FunctionDef.new(
          "test",
          [],
          Node::ReturnStatement.new(Node::Integer.new(42))
        )
        subject.evaluate(func_def)

        # 関数呼び出し: test()
        func_call = Node::FunctionCall.new("test", [])
        result = subject.evaluate(func_call)

        expect(result).to eq(42)
      end

      it "calls function with single parameter" do
        # 関数定義: func double(x) { return x * 2 }
        func_def = Node::FunctionDef.new(
          "double",
          ["x"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("x"),
              :asterisk,
              Node::Integer.new(2)
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し: double(5)
        func_call = Node::FunctionCall.new("double", [Node::Integer.new(5)])
        result = subject.evaluate(func_call)

        expect(result).to eq(10)
      end

      it "calls function with multiple parameters" do
        # 関数定義: func add(a, b) { return a + b }
        func_def = Node::FunctionDef.new(
          "add",
          ["a", "b"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("a"),
              :plus,
              Node::Variable.new("b")
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し: add(3, 4)
        func_call = Node::FunctionCall.new("add", [Node::Integer.new(3), Node::Integer.new(4)])
        result = subject.evaluate(func_call)

        expect(result).to eq(7)
      end

      it "calls function with variable arguments" do
        # グローバル変数設定
        subject.evaluate(Node::Assignment.new("x", Node::Integer.new(10)))
        subject.evaluate(Node::Assignment.new("y", Node::Integer.new(20)))

        # 関数定義: func multiply(a, b) { return a * b }
        func_def = Node::FunctionDef.new(
          "multiply",
          ["a", "b"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("a"),
              :asterisk,
              Node::Variable.new("b")
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し: multiply(x, y)
        func_call = Node::FunctionCall.new("multiply", [
          Node::Variable.new("x"),
          Node::Variable.new("y")
        ])
        result = subject.evaluate(func_call)

        expect(result).to eq(200)
      end

      it "calls function with expression arguments" do
        # 関数定義: func add(a, b) { return a + b }
        func_def = Node::FunctionDef.new(
          "add",
          ["a", "b"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("a"),
              :plus,
              Node::Variable.new("b")
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し: add(1 + 2, 3 * 4)
        func_call = Node::FunctionCall.new("add", [
          Node::BinaryOp.new(Node::Integer.new(1), :plus, Node::Integer.new(2)),
          Node::BinaryOp.new(Node::Integer.new(3), :asterisk, Node::Integer.new(4))
        ])
        result = subject.evaluate(func_call)

        expect(result).to eq(15) # (1+2) + (3*4) = 3 + 12 = 15
      end

      it "calls function with string parameters" do
        # 関数定義: func greet(name) { return "Hello " + name }
        func_def = Node::FunctionDef.new(
          "greet",
          ["name"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::String.new("Hello "),
              :plus,
              Node::Variable.new("name")
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し: greet("Alice")
        func_call = Node::FunctionCall.new("greet", [Node::String.new("Alice")])
        result = subject.evaluate(func_call)

        expect(result).to eq("Hello Alice")
      end

      it "calls function with ? and ! in name" do
        # 関数定義: func even?(n) { return n / 2 * 2 == n }
        func_def = Node::FunctionDef.new(
          "even?",
          ["n"],
          Node::ReturnStatement.new(
            Node::ComparisonOp.new(
              Node::BinaryOp.new(
                Node::BinaryOp.new(
                  Node::Variable.new("n"),
                  :slash,
                  Node::Integer.new(2)
                ),
                :asterisk,
                Node::Integer.new(2)
              ),
              :equal_equal,
              Node::Variable.new("n")
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し: even?(4)
        func_call = Node::FunctionCall.new("even?", [Node::Integer.new(4)])
        expect(subject.evaluate(func_call)).to eq(true)

        # 関数呼び出し: even?(5)
        func_call = Node::FunctionCall.new("even?", [Node::Integer.new(5)])
        expect(subject.evaluate(func_call)).to eq(false)
      end
    end

    # STEP9新機能: return文のテスト
    describe "return statements" do
      it "evaluates return with value" do
        return_stmt = Node::ReturnStatement.new(Node::Integer.new(42))

        expect {
          subject.evaluate(return_stmt)
        }.to raise_error(subject.class::ReturnException) do |exception|
          expect(exception.value).to eq(42)
        end
      end

      it "evaluates return with expression" do
        return_stmt = Node::ReturnStatement.new(
          Node::BinaryOp.new(
            Node::Integer.new(3),
            :plus,
            Node::Integer.new(4)
          )
        )

        expect {
          subject.evaluate(return_stmt)
        }.to raise_error(subject.class::ReturnException) do |exception|
          expect(exception.value).to eq(7)
        end
      end

      it "evaluates return without value (returns nil)" do
        return_stmt = Node::ReturnStatement.new(nil)

        expect {
          subject.evaluate(return_stmt)
        }.to raise_error(subject.class::ReturnException) do |exception|
          expect(exception.value).to be_nil
        end
      end

      it "handles return in function context" do
        # 関数定義: func test() { x = 5; return x * 2; y = 10 }
        func_def = Node::FunctionDef.new(
          "test",
          [],
          Node::Block.new([
            Node::Assignment.new("x", Node::Integer.new(5)),
            Node::ReturnStatement.new(
              Node::BinaryOp.new(
                Node::Variable.new("x"),
                :asterisk,
                Node::Integer.new(2)
              )
            ),
            Node::Assignment.new("y", Node::Integer.new(10)) # これは実行されない
          ])
        )
        subject.evaluate(func_def)

        # 関数呼び出し
        func_call = Node::FunctionCall.new("test", [])
        result = subject.evaluate(func_call)

        expect(result).to eq(10) # x * 2 = 5 * 2 = 10
      end
    end

    # STEP9新機能: スコープ管理のテスト
    describe "scope management" do
      it "maintains separate local and global scope" do
        # グローバル変数
        subject.evaluate(Node::Assignment.new("global_var", Node::Integer.new(100)))

        # 関数定義: func test(local_param) { local_var = 42; return local_param + local_var + global_var }
        func_def = Node::FunctionDef.new(
          "test",
          ["local_param"],
          Node::Block.new([
            Node::Assignment.new("local_var", Node::Integer.new(42)),
            Node::ReturnStatement.new(
              Node::BinaryOp.new(
                Node::BinaryOp.new(
                  Node::Variable.new("local_param"),
                  :plus,
                  Node::Variable.new("local_var")
                ),
                :plus,
                Node::Variable.new("global_var")
              )
            )
          ])
        )
        subject.evaluate(func_def)

        # 関数呼び出し
        func_call = Node::FunctionCall.new("test", [Node::Integer.new(10)])
        result = subject.evaluate(func_call)

        expect(result).to eq(152) # 10 + 42 + 100 = 152

        # ローカル変数は関数外からアクセスできない
        expect {
          subject.evaluate(Node::Variable.new("local_var"))
        }.to raise_error(/未定義の変数/)

        expect {
          subject.evaluate(Node::Variable.new("local_param"))
        }.to raise_error(/未定義の変数/)

        # グローバル変数はアクセス可能
        expect(subject.evaluate(Node::Variable.new("global_var"))).to eq(100)
      end

      it "allows function to modify global variables" do
        # グローバル変数
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))

        # 関数定義: func increment() { counter = counter + 1; return counter }
        func_def = Node::FunctionDef.new(
          "increment",
          [],
          Node::Block.new([
            Node::Assignment.new(
              "counter",
              Node::BinaryOp.new(
                Node::Variable.new("counter"),
                :plus,
                Node::Integer.new(1)
              )
            ),
            Node::ReturnStatement.new(Node::Variable.new("counter"))
          ])
        )
        subject.evaluate(func_def)

        # 関数呼び出し
        func_call = Node::FunctionCall.new("increment", [])
        result1 = subject.evaluate(func_call)
        result2 = subject.evaluate(func_call)

        expect(result1).to eq(1)
        expect(result2).to eq(2)
        expect(subject.evaluate(Node::Variable.new("counter"))).to eq(2)
      end

      it "handles parameter shadowing" do
        # グローバル変数
        subject.evaluate(Node::Assignment.new("x", Node::Integer.new(100)))

        # 関数定義: func test(x) { return x * 2 } (パラメータがグローバル変数をシャドウ)
        func_def = Node::FunctionDef.new(
          "test",
          ["x"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("x"),
              :asterisk,
              Node::Integer.new(2)
            )
          )
        )
        subject.evaluate(func_def)

        # 関数呼び出し
        func_call = Node::FunctionCall.new("test", [Node::Integer.new(5)])
        result = subject.evaluate(func_call)

        expect(result).to eq(10) # パラメータのx (5) * 2 = 10
        expect(subject.evaluate(Node::Variable.new("x"))).to eq(100) # グローバルのxは変更されない
      end
    end

    # STEP9新機能: 再帰関数のテスト
    describe "recursive functions" do
      it "evaluates factorial function" do
        # 関数定義: func factorial(n) { if < n =< 1 > { return 1 } else { return n * factorial(n - 1) } }
        condition = Node::ComparisonOp.new(
          Node::Variable.new("n"),
          :equal_less,
          Node::Integer.new(1)
        )
        then_body = Node::ReturnStatement.new(Node::Integer.new(1))
        else_body = Node::ReturnStatement.new(
          Node::BinaryOp.new(
            Node::Variable.new("n"),
            :asterisk,
            Node::FunctionCall.new("factorial", [
              Node::BinaryOp.new(
                Node::Variable.new("n"),
                :minus,
                Node::Integer.new(1)
              )
            ])
          )
        )
        if_stmt = Node::IfStatement.new(condition, then_body, [], else_body)

        func_def = Node::FunctionDef.new("factorial", ["n"], if_stmt)
        subject.evaluate(func_def)

        # テスト
        expect(subject.evaluate(Node::FunctionCall.new("factorial", [Node::Integer.new(0)]))).to eq(1)
        expect(subject.evaluate(Node::FunctionCall.new("factorial", [Node::Integer.new(1)]))).to eq(1)
        expect(subject.evaluate(Node::FunctionCall.new("factorial", [Node::Integer.new(3)]))).to eq(6)
        expect(subject.evaluate(Node::FunctionCall.new("factorial", [Node::Integer.new(5)]))).to eq(120)
      end

      it "evaluates countdown function with side effects" do
        # 関数定義: func countdown(n) { if < n =< 0 > { return } else { hyouji(n); countdown(n - 1) } }
        condition = Node::ComparisonOp.new(
          Node::Variable.new("n"),
          :equal_less,
          Node::Integer.new(0)
        )
        then_body = Node::ReturnStatement.new(nil)
        else_body = Node::Block.new([
          Node::HyoujiStatement.new(Node::Variable.new("n")),
          Node::FunctionCall.new("countdown", [
            Node::BinaryOp.new(
              Node::Variable.new("n"),
              :minus,
              Node::Integer.new(1)
            )
          ])
        ])
        if_stmt = Node::IfStatement.new(condition, then_body, [], else_body)

        func_def = Node::FunctionDef.new("countdown", ["n"], if_stmt)
        subject.evaluate(func_def)

        # テスト
        expect {
          subject.evaluate(Node::FunctionCall.new("countdown", [Node::Integer.new(3)]))
        }.to output("3\n2\n1\n").to_stdout
      end
    end

    # STEP9新機能: 複雑な関数シナリオのテスト
    describe "complex function scenarios" do
      it "calls function within function" do
        # 関数定義: func add(a, b) { return a + b }
        add_def = Node::FunctionDef.new(
          "add",
          ["a", "b"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("a"),
              :plus,
              Node::Variable.new("b")
            )
          )
        )
        subject.evaluate(add_def)

        # 関数定義: func calculate(x, y) { return add(x * 2, y + 1) }
        calc_def = Node::FunctionDef.new(
          "calculate",
          ["x", "y"],
          Node::ReturnStatement.new(
            Node::FunctionCall.new("add", [
              Node::BinaryOp.new(
                Node::Variable.new("x"),
                :asterisk,
                Node::Integer.new(2)
              ),
              Node::BinaryOp.new(
                Node::Variable.new("y"),
                :plus,
                Node::Integer.new(1)
              )
            ])
          )
        )
        subject.evaluate(calc_def)

        # テスト: calculate(3, 4) = add(3*2, 4+1) = add(6, 5) = 11
        result = subject.evaluate(Node::FunctionCall.new("calculate", [
          Node::Integer.new(3),
          Node::Integer.new(4)
        ]))
        expect(result).to eq(11)
      end

      it "handles functions with no explicit return (returns last expression)" do
        # 関数定義: func test(x) { y = x + 1; y * 2 } (最後の式が戻り値)
        func_def = Node::FunctionDef.new(
          "test",
          ["x"],
          Node::Block.new([
            Node::Assignment.new(
              "y",
              Node::BinaryOp.new(
                Node::Variable.new("x"),
                :plus,
                Node::Integer.new(1)
              )
            ),
            Node::BinaryOp.new(
              Node::Variable.new("y"),
              :asterisk,
              Node::Integer.new(2)
            )
          ])
        )
        subject.evaluate(func_def)

        # テスト: test(5) = (5+1)*2 = 12
        result = subject.evaluate(Node::FunctionCall.new("test", [Node::Integer.new(5)]))
        expect(result).to eq(12)
      end

      it "handles function with side effects" do
        # グローバル変数
        subject.evaluate(Node::Assignment.new("log", Node::String.new("")))

        # 関数定義: func log_and_add(a, b) { log = log + "Adding " + a + " and " + b; return a + b }
        func_def = Node::FunctionDef.new(
          "log_and_add",
          ["a", "b"],
          Node::Block.new([
            Node::Assignment.new(
              "log",
              Node::BinaryOp.new(
                Node::BinaryOp.new(
                  Node::BinaryOp.new(
                    Node::BinaryOp.new(
                      Node::Variable.new("log"),
                      :plus,
                      Node::String.new("Adding ")
                    ),
                    :plus,
                    Node::Variable.new("a")
                  ),
                  :plus,
                  Node::String.new(" and ")
                ),
                :plus,
                Node::Variable.new("b")
              )
            ),
            Node::ReturnStatement.new(
              Node::BinaryOp.new(
                Node::Variable.new("a"),
                :plus,
                Node::Variable.new("b")
              )
            )
          ])
        )
        subject.evaluate(func_def)

        # テスト
        result = subject.evaluate(Node::FunctionCall.new("log_and_add", [
          Node::Integer.new(3),
          Node::Integer.new(4)
        ]))

        expect(result).to eq(7)
        expect(subject.evaluate(Node::Variable.new("log"))).to eq("Adding 3 and 4")
      end
    end

    # STEP9新機能: エラーケースのテスト
    describe "function error handling" do
      it "raises error for undefined function" do
        func_call = Node::FunctionCall.new("undefined_function", [])

        expect {
          subject.evaluate(func_call)
        }.to raise_error(/未定義の関数です: undefined_function/)
      end

      it "raises error for wrong number of arguments" do
        # 関数定義: func add(a, b) { return a + b }
        func_def = Node::FunctionDef.new(
          "add",
          ["a", "b"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::Variable.new("a"),
              :plus,
              Node::Variable.new("b")
            )
          )
        )
        subject.evaluate(func_def)

        # 引数が少ない場合
        expect {
          subject.evaluate(Node::FunctionCall.new("add", [Node::Integer.new(1)]))
        }.to raise_error(/Wrong number of arguments for 'add': expected 2, got 1/)

        # 引数が多い場合
        expect {
          subject.evaluate(Node::FunctionCall.new("add", [
            Node::Integer.new(1),
            Node::Integer.new(2),
            Node::Integer.new(3)
          ]))
        }.to raise_error(/Wrong number of arguments for 'add': expected 2, got 3/)
      end

      it "handles maximum recursion depth" do
        # 無限再帰を引き起こす関数
        func_def = Node::FunctionDef.new(
          "infinite_recursion",
          [],
          Node::FunctionCall.new("infinite_recursion", [])
        )
        subject.evaluate(func_def)

        expect {
          subject.evaluate(Node::FunctionCall.new("infinite_recursion", []))
        }.to raise_error(/Maximum recursion depth exceeded/)
      end
    end

    # STEP9新機能: 関数と他の機能の統合テスト
    describe "function integration tests" do
      it "uses functions in if conditions" do
        # 関数定義: func even?(n) { return n / 2 * 2 == n }
        func_def = Node::FunctionDef.new(
          "even?",
          ["n"],
          Node::ReturnStatement.new(
            Node::ComparisonOp.new(
              Node::BinaryOp.new(
                Node::BinaryOp.new(
                  Node::Variable.new("n"),
                  :slash,
                  Node::Integer.new(2)
                ),
                :asterisk,
                Node::Integer.new(2)
              ),
              :equal_equal,
              Node::Variable.new("n")
            )
          )
        )
        subject.evaluate(func_def)

        # if < even?(4) > { result = "even" } else { result = "odd" }
        condition = Node::FunctionCall.new("even?", [Node::Integer.new(4)])
        then_body = Node::Assignment.new("result", Node::String.new("even"))
        else_body = Node::Assignment.new("result", Node::String.new("odd"))
        if_stmt = Node::IfStatement.new(condition, then_body, [], else_body)

        subject.evaluate(if_stmt)
        expect(subject.evaluate(Node::Variable.new("result"))).to eq("even")
      end

      it "uses functions in while loops" do
        subject.evaluate(Node::Assignment.new("counter", Node::Integer.new(0)))

        # 関数定義: func increment() { counter = counter + 1; return counter }
        func_def = Node::FunctionDef.new(
          "increment",
          [],
          Node::Block.new([
            Node::Assignment.new(
              "counter",
              Node::BinaryOp.new(
                Node::Variable.new("counter"),
                :plus,
                Node::Integer.new(1)
              )
            ),
            Node::ReturnStatement.new(Node::Variable.new("counter"))
          ])
        )
        subject.evaluate(func_def)

        # while < counter < 3 > { increment() }
        condition = Node::ComparisonOp.new(
          Node::Variable.new("counter"),
          :less,
          Node::Integer.new(3)
        )
        body = Node::FunctionCall.new("increment", [])
        while_stmt = Node::WhileStatement.new(condition, body)

        subject.evaluate(while_stmt)
        expect(subject.evaluate(Node::Variable.new("counter"))).to eq(3)
      end

      it "uses functions in hyouji statements" do
        # 関数定義: func get_greeting(name) { return "Hello " + name }
        func_def = Node::FunctionDef.new(
          "get_greeting",
          ["name"],
          Node::ReturnStatement.new(
            Node::BinaryOp.new(
              Node::String.new("Hello "),
              :plus,
              Node::Variable.new("name")
            )
          )
        )
        subject.evaluate(func_def)

        # hyouji(get_greeting("Alice"))
        hyouji_stmt = Node::HyoujiStatement.new(
          Node::FunctionCall.new("get_greeting", [Node::String.new("Alice")])
        )

        expect {
          subject.evaluate(hyouji_stmt)
        }.to output("Hello Alice\n").to_stdout
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
