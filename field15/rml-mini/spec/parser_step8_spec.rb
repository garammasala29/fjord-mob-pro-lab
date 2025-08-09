# spec/parser_step8_spec.rb
require_relative "../lib/parser_step8"
require_relative "../lib/node"

RSpec.describe ParserStep8 do
  subject { described_class }

  describe ".parse" do
    # Step5からの継承テスト
    describe "variable assignment and reference (from Step5)" do
      it "変数代入をパースする" do
        ast = subject.parse("x = 42")

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("x")
        expect(ast.value).to be_a(Node::Integer)
        expect(ast.value.value).to eq(42)
      end

      it "変数参照をパースする" do
        ast = subject.parse("x")

        expect(ast).to be_a(Node::Variable)
        expect(ast.name).to eq("x")
      end

      it "変数を含む式をパースする" do
        ast = subject.parse("x + 5")

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.lhs).to be_a(Node::Variable)
        expect(ast.lhs.name).to eq("x")
        expect(ast.op).to eq(:plus)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(5)
      end
    end

    # Step4からの継承テスト
    describe "arithmetic operations (from Step4)" do
      it "parses simple integer" do
        ast = subject.parse("42")

        expect(ast).to be_a(Node::Integer)
        expect(ast.value).to eq(42)
      end

      it "parses simple addition" do
        ast = subject.parse("1 + 2")

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(1)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(2)
      end

      it "parses parenthesized expression" do
        ast = subject.parse("(1 + 2)")

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
      end

      it "parses complex expressions with operator precedence" do
        ast = subject.parse("1 + 2 * 3")

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(1)
        expect(ast.rhs).to be_a(Node::BinaryOp)
        expect(ast.rhs.op).to eq(:asterisk)
      end

      it "parses expressions with parentheses changing precedence" do
        ast = subject.parse("(1 + 2) * 3")

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:asterisk)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:plus)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(3)
      end
    end

    # Boolean型のテスト
    describe "boolean literals" do
      it "parses true" do
        ast = subject.parse("true")

        expect(ast).to be_a(Node::Boolean)
        expect(ast.value).to eq(true)
      end

      it "parses false" do
        ast = subject.parse("false")

        expect(ast).to be_a(Node::Boolean)
        expect(ast.value).to eq(false)
      end

      it "parses boolean assignment" do
        ast = subject.parse("flag = true")

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("flag")
        expect(ast.value).to be_a(Node::Boolean)
        expect(ast.value.value).to eq(true)
      end
    end

    # STEP8新機能: 文字列リテラルのテスト
    describe "string literals" do
      it "parses simple double-quoted string" do
        ast = subject.parse('"Hello"')

        expect(ast).to be_a(Node::String)
        expect(ast.value).to eq("Hello")
      end

      it "parses simple single-quoted string" do
        ast = subject.parse("'World'")

        expect(ast).to be_a(Node::String)
        expect(ast.value).to eq("World")
      end

      it "parses empty string" do
        ast = subject.parse('""')

        expect(ast).to be_a(Node::String)
        expect(ast.value).to eq("")
      end

      it "parses string with spaces" do
        ast = subject.parse('"Hello World"')

        expect(ast).to be_a(Node::String)
        expect(ast.value).to eq("Hello World")
      end

      it "parses string with escape sequences" do
        ast = subject.parse('"Hello\\nWorld"')

        expect(ast).to be_a(Node::String)
        expect(ast.value).to eq("Hello\nWorld")
      end

      it "parses string assignment" do
        ast = subject.parse('message = "Hello World"')

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("message")
        expect(ast.value).to be_a(Node::String)
        expect(ast.value.value).to eq("Hello World")
      end

      it "parses string with quotes inside" do
        ast = subject.parse('"She said \\"Hello\\""')

        expect(ast).to be_a(Node::String)
        expect(ast.value).to eq('She said "Hello"')
      end
    end

    # STEP8新機能: 文字列連結のテスト
    describe "string concatenation" do
      it "parses string + string" do
        ast = subject.parse('"Hello " + "World"')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::String)
        expect(ast.lhs.value).to eq("Hello ")
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("World")
      end

      it "parses string + variable" do
        ast = subject.parse('"Hello " + name')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::String)
        expect(ast.lhs.value).to eq("Hello ")
        expect(ast.rhs).to be_a(Node::Variable)
        expect(ast.rhs.name).to eq("name")
      end

      it "parses string + number" do
        ast = subject.parse('"Count: " + 42')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::String)
        expect(ast.lhs.value).to eq("Count: ")
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(42)
      end

      it "parses variable + string" do
        ast = subject.parse('name + " World"')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::Variable)
        expect(ast.lhs.name).to eq("name")
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq(" World")
      end

      it "parses multiple string concatenations" do
        ast = subject.parse('"Hello " + name + "!"')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:plus)
        expect(ast.lhs.lhs).to be_a(Node::String)
        expect(ast.lhs.lhs.value).to eq("Hello ")
        expect(ast.lhs.rhs).to be_a(Node::Variable)
        expect(ast.lhs.rhs.name).to eq("name")
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("!")
      end

      it "parses parenthesized string concatenation" do
        ast = subject.parse('("Hello " + name) + "!"')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:plus)
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("!")
      end
    end

    # STEP8新機能: hyouji文のテスト
    describe "hyouji statements" do
      it "parses simple hyouji with string" do
        ast = subject.parse('hyouji("Hello World")')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::String)
        expect(ast.expression.value).to eq("Hello World")
      end

      it "parses hyouji with variable" do
        ast = subject.parse('hyouji(message)')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::Variable)
        expect(ast.expression.name).to eq("message")
      end

      it "parses hyouji with number" do
        ast = subject.parse('hyouji(42)')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::Integer)
        expect(ast.expression.value).to eq(42)
      end

      it "parses hyouji with boolean" do
        ast = subject.parse('hyouji(true)')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::Boolean)
        expect(ast.expression.value).to eq(true)
      end

      it "parses hyouji with string concatenation" do
        ast = subject.parse('hyouji("Hello " + name)')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::BinaryOp)
        expect(ast.expression.op).to eq(:plus)
        expect(ast.expression.lhs).to be_a(Node::String)
        expect(ast.expression.lhs.value).to eq("Hello ")
        expect(ast.expression.rhs).to be_a(Node::Variable)
        expect(ast.expression.rhs.name).to eq("name")
      end

      it "parses hyouji with arithmetic expression" do
        ast = subject.parse('hyouji(x + y)')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::BinaryOp)
        expect(ast.expression.op).to eq(:plus)
        expect(ast.expression.lhs).to be_a(Node::Variable)
        expect(ast.expression.lhs.name).to eq("x")
        expect(ast.expression.rhs).to be_a(Node::Variable)
        expect(ast.expression.rhs.name).to eq("y")
      end

      it "parses hyouji with comparison expression" do
        ast = subject.parse('hyouji(x > 5)')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::ComparisonOp)
        expect(ast.expression.op).to eq(:greater)
        expect(ast.expression.lhs).to be_a(Node::Variable)
        expect(ast.expression.lhs.name).to eq("x")
        expect(ast.expression.rhs).to be_a(Node::Integer)
        expect(ast.expression.rhs.value).to eq(5)
      end

      it "parses hyouji with complex expression" do
        ast = subject.parse('hyouji("Result: " + (x * 2))')

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::BinaryOp)
        expect(ast.expression.op).to eq(:plus)
        expect(ast.expression.lhs).to be_a(Node::String)
        expect(ast.expression.lhs.value).to eq("Result: ")
        expect(ast.expression.rhs).to be_a(Node::BinaryOp)
        expect(ast.expression.rhs.op).to eq(:asterisk)
      end
    end

    # 比較演算子のテスト（既存）
    describe "comparison operators" do
      it "parses equality ==" do
        ast = subject.parse("5 == 3")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_equal)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(5)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(3)
      end

      it "parses string comparison" do
        ast = subject.parse('"hello" == "world"')

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_equal)
        expect(ast.lhs).to be_a(Node::String)
        expect(ast.lhs.value).to eq("hello")
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("world")
      end

      it "parses string and variable comparison" do
        ast = subject.parse('name == "Alice"')

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_equal)
        expect(ast.lhs).to be_a(Node::Variable)
        expect(ast.lhs.name).to eq("name")
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("Alice")
      end
    end

    # 演算子優先順位テスト（文字列込み）
    describe "operator precedence with strings" do
      it "string concatenation has same precedence as addition" do
        # "a" + "b" + "c" should be left-associative: ("a" + "b") + "c"
        ast = subject.parse('"a" + "b" + "c"')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:plus)
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("c")
      end

      it "arithmetic has higher precedence than string concatenation" do
        # "Count: " + 2 * 3 should be "Count: " + (2 * 3)
        ast = subject.parse('"Count: " + 2 * 3')

        expect(ast).to be_a(Node::BinaryOp)
        expect(ast.op).to eq(:plus)
        expect(ast.lhs).to be_a(Node::String)
        expect(ast.lhs.value).to eq("Count: ")
        expect(ast.rhs).to be_a(Node::BinaryOp)
        expect(ast.rhs.op).to eq(:asterisk)
      end

      it "string concatenation has lower precedence than comparison" do
        # "a" + "b" == "c" should be ("a" + "b") == "c"
        ast = subject.parse('"a" + "b" == "c"')

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_equal)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:plus)
        expect(ast.rhs).to be_a(Node::String)
        expect(ast.rhs.value).to eq("c")
      end
    end

    # if文のテスト（既存）
    describe "if statements" do
      it "parses if with string condition" do
        ast = subject.parse('if < name == "Alice" > { result = 1 }')

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:equal_equal)
        expect(ast.condition.lhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.name).to eq("name")
        expect(ast.condition.rhs).to be_a(Node::String)
        expect(ast.condition.rhs.value).to eq("Alice")
      end

      it "parses if with hyouji in body" do
        ast = subject.parse('if < x > 0 > { hyouji("Positive") }')

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.then_body).to be_a(Node::HyoujiStatement)
        expect(ast.then_body.expression).to be_a(Node::String)
        expect(ast.then_body.expression.value).to eq("Positive")
      end

      it "parses if with string assignment in body" do
        ast = subject.parse('if < score => 90 > { grade = "A" }')

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.then_body).to be_a(Node::Assignment)
        expect(ast.then_body.name).to eq("grade")
        expect(ast.then_body.value).to be_a(Node::String)
        expect(ast.then_body.value.value).to eq("A")
      end
    end

    # while文のテスト（既存）
    describe "while statements" do
      it "parses while with hyouji in body" do
        ast = subject.parse('while < counter < 3 > { hyouji("Count: " + counter) }')

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.body).to be_a(Node::HyoujiStatement)
        expect(ast.body.expression).to be_a(Node::BinaryOp)
        expect(ast.body.expression.op).to eq(:plus)
        expect(ast.body.expression.lhs).to be_a(Node::String)
        expect(ast.body.expression.lhs.value).to eq("Count: ")
      end

      it "parses while with string assignment" do
        ast = subject.parse('while < running > { status = "processing" }')

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.body).to be_a(Node::Assignment)
        expect(ast.body.name).to eq("status")
        expect(ast.body.value).to be_a(Node::String)
        expect(ast.body.value.value).to eq("processing")
      end
    end

    # STEP8新機能: 複合的なテスト
    describe "step8 complex expressions" do
      it "parses assignment with string concatenation" do
        ast = subject.parse('greeting = "Hello " + name + "!"')

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("greeting")
        expect(ast.value).to be_a(Node::BinaryOp)
        expect(ast.value.op).to eq(:plus)
      end

      it "parses if-else with hyouji statements" do
        ast = subject.parse('if < x > 0 > { hyouji("Positive") } else { hyouji("Non-positive") }')

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.then_body).to be_a(Node::HyoujiStatement)
        expect(ast.else_body).to be_a(Node::HyoujiStatement)
        expect(ast.then_body.expression.value).to eq("Positive")
        expect(ast.else_body.expression.value).to eq("Non-positive")
      end

      it "parses while with multiple statements including hyouji" do
        ast = subject.parse('while < i < 3 > { hyouji("Count: " + i) i = i + 1 }')

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.body).to be_a(Node::Block)
        expect(ast.body.statements).to have_attributes(size: 2)
        expect(ast.body.statements[0]).to be_a(Node::HyoujiStatement)
        expect(ast.body.statements[1]).to be_a(Node::Assignment)
      end

      it "parses nested expressions with strings and numbers" do
        ast = subject.parse('result = "Value: " + (x + y) * 2')

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("result")
        expect(ast.value).to be_a(Node::BinaryOp)
        expect(ast.value.op).to eq(:plus)
        expect(ast.value.lhs).to be_a(Node::String)
        expect(ast.value.rhs).to be_a(Node::BinaryOp)
        expect(ast.value.rhs.op).to eq(:asterisk)
      end
    end

    # エラーケース
    describe "error handling" do
      it "raises error on malformed hyouji statement" do
        expect { subject.parse("hyouji") }.to raise_error(/Expected/)
        expect { subject.parse("hyouji(") }.to raise_error(/Unexpected/)
        expect { subject.parse("hyouji)") }.to raise_error(/Expected/)
        expect { subject.parse('hyouji("hello"') }.to raise_error(/Expected/)
        expect { subject.parse('hyouji"hello")') }.to raise_error(/Expected/)
      end

      it "raises error on empty hyouji" do
        expect { subject.parse("hyouji()") }.to raise_error(/Unexpected/)
      end

      it "raises error on unterminated string (should be caught by lexer)" do
        expect { subject.parse('"hello') }.to raise_error(/Unterminated/)
        expect { subject.parse("'world") }.to raise_error(/Unterminated/)
      end

      it "raises error on unbalanced parentheses" do
        expect { subject.parse("(2 + 3") }.to raise_error(RuntimeError)
        expect { subject.parse("2 + 3)") }.to raise_error(RuntimeError)
      end

      it "raises error on malformed string concatenation" do
        expect { subject.parse('"hello" +') }.to raise_error(/Unexpected/)
        expect { subject.parse('+ "world"') }.to raise_error(/Unexpected/)
      end

      it "raises error on unexpected tokens" do
        expect { subject.parse("5 + + 3") }.to raise_error(/Unexpected/)
        expect { subject.parse("if < > { x = 1 }") }.to raise_error(/Unexpected/)
      end

      it "raises error on incomplete expressions" do
        expect { subject.parse("5 +") }.to raise_error(/Unexpected/)
        expect { subject.parse("x =") }.to raise_error(/Unexpected/)
        expect { subject.parse("5 ==") }.to raise_error(/Unexpected/)
      end
    end
  end
end
