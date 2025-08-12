# spec/parser_step8_spec.rb
require_relative "../lib/parser_step9"
require_relative "../lib/node"

RSpec.describe ParserStep9 do
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

    # STEP9新機能: 関数定義のテスト
    describe "function definitions" do
      it "parses simple function without parameters" do
        ast = subject.parse("func test() { return 42 }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("test")
        expect(ast.parameters).to eq([])
        expect(ast.body).to be_a(Node::ReturnStatement)
        expect(ast.body.expression).to be_a(Node::Integer)
        expect(ast.body.expression.value).to eq(42)
      end

      it "parses function with single parameter" do
        ast = subject.parse("func double(x) { return x * 2 }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("double")
        expect(ast.parameters).to eq(["x"])
        expect(ast.body).to be_a(Node::ReturnStatement)
        expect(ast.body.expression).to be_a(Node::BinaryOp)
        expect(ast.body.expression.op).to eq(:asterisk)
      end

      it "parses function with multiple parameters" do
        ast = subject.parse("func add(a, b) { return a + b }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("add")
        expect(ast.parameters).to eq(["a", "b"])
        expect(ast.body).to be_a(Node::ReturnStatement)
      end

      it "parses function with three parameters" do
        ast = subject.parse("func sum(x, y, z) { return x + y + z }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("sum")
        expect(ast.parameters).to eq(["x", "y", "z"])
      end

      it "parses function with question mark in name" do
        ast = subject.parse("func even?(n) { return n / 2 * 2 == n }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("even?")
        expect(ast.parameters).to eq(["n"])
      end

      it "parses function with exclamation mark in name" do
        ast = subject.parse("func reset!() { x = 0 }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("reset!")
        expect(ast.parameters).to eq([])
      end

      it "parses function without return statement" do
        ast = subject.parse("func greet() { hyouji(\"Hello\") }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("greet")
        expect(ast.body).to be_a(Node::HyoujiStatement)
      end

      it "parses function with multiple statements" do
        ast = subject.parse("func test() { x = 5 hyouji(x) return x }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.body).to be_a(Node::Block)
        expect(ast.body.statements).to have_attributes(size: 3)
        expect(ast.body.statements[0]).to be_a(Node::Assignment)
        expect(ast.body.statements[1]).to be_a(Node::HyoujiStatement)
        expect(ast.body.statements[2]).to be_a(Node::ReturnStatement)
      end

      it "parses function with conditional logic" do
        ast = subject.parse("func abs(n) { if < n < 0 > { return 0 - n } else { return n } }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("abs")
        expect(ast.body).to be_a(Node::IfStatement)
        expect(ast.body.then_body).to be_a(Node::ReturnStatement)
        expect(ast.body.else_body).to be_a(Node::ReturnStatement)
      end

      it "parses function with while loop" do
        ast = subject.parse("func countdown(n) { while < n > 0 > { hyouji(n) n = n - 1 } }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("countdown")
        expect(ast.body).to be_a(Node::WhileStatement)
      end
    end

    # STEP9新機能: 関数呼び出しのテスト
    describe "function calls" do
      it "parses simple function call without arguments" do
        ast = subject.parse("test()")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.name).to eq("test")
        expect(ast.arguments).to eq([])
      end

      it "parses function call with single argument" do
        ast = subject.parse("double(5)")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.name).to eq("double")
        expect(ast.arguments).to have_attributes(size: 1)
        expect(ast.arguments[0]).to be_a(Node::Integer)
        expect(ast.arguments[0].value).to eq(5)
      end

      it "parses function call with multiple arguments" do
        ast = subject.parse("add(3, 4)")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.name).to eq("add")
        expect(ast.arguments).to have_attributes(size: 2)
        expect(ast.arguments[0]).to be_a(Node::Integer)
        expect(ast.arguments[0].value).to eq(3)
        expect(ast.arguments[1]).to be_a(Node::Integer)
        expect(ast.arguments[1].value).to eq(4)
      end

      it "parses function call with variable arguments" do
        ast = subject.parse("multiply(x, y)")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.name).to eq("multiply")
        expect(ast.arguments).to have_attributes(size: 2)
        expect(ast.arguments[0]).to be_a(Node::Variable)
        expect(ast.arguments[0].name).to eq("x")
        expect(ast.arguments[1]).to be_a(Node::Variable)
        expect(ast.arguments[1].name).to eq("y")
      end

      it "parses function call with expression arguments" do
        ast = subject.parse("add(1 + 2, 3 * 4)")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.arguments).to have_attributes(size: 2)
        expect(ast.arguments[0]).to be_a(Node::BinaryOp)
        expect(ast.arguments[0].op).to eq(:plus)
        expect(ast.arguments[1]).to be_a(Node::BinaryOp)
        expect(ast.arguments[1].op).to eq(:asterisk)
      end

      it "parses function call with string arguments" do
        ast = subject.parse('greet("Alice", "Hello")')

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.arguments).to have_attributes(size: 2)
        expect(ast.arguments[0]).to be_a(Node::String)
        expect(ast.arguments[0].value).to eq("Alice")
        expect(ast.arguments[1]).to be_a(Node::String)
        expect(ast.arguments[1].value).to eq("Hello")
      end

      it "parses function call with ? and ! in name" do
        ast = subject.parse("even?(42)")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.name).to eq("even?")
        expect(ast.arguments[0]).to be_a(Node::Integer)
        expect(ast.arguments[0].value).to eq(42)
      end

      it "parses nested function calls" do
        ast = subject.parse("add(double(5), triple(3))")

        expect(ast).to be_a(Node::FunctionCall)
        expect(ast.name).to eq("add")
        expect(ast.arguments).to have_attributes(size: 2)
        expect(ast.arguments[0]).to be_a(Node::FunctionCall)
        expect(ast.arguments[0].name).to eq("double")
        expect(ast.arguments[1]).to be_a(Node::FunctionCall)
        expect(ast.arguments[1].name).to eq("triple")
      end
    end

    # STEP9新機能: return文のテスト
    describe "return statements" do
      it "parses return with value" do
        ast = subject.parse("return 42")

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_a(Node::Integer)
        expect(ast.expression.value).to eq(42)
      end

      it "parses return with variable" do
        ast = subject.parse("return x")

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_a(Node::Variable)
        expect(ast.expression.name).to eq("x")
      end

      it "parses return with expression" do
        ast = subject.parse("return x + y")

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_a(Node::BinaryOp)
        expect(ast.expression.op).to eq(:plus)
      end

      it "parses return with function call" do
        ast = subject.parse("return factorial(n - 1)")

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_a(Node::FunctionCall)
        expect(ast.expression.name).to eq("factorial")
        expect(ast.expression.arguments[0]).to be_a(Node::BinaryOp)
        expect(ast.expression.arguments[0].op).to eq(:minus)
      end

      it "parses return with string" do
        ast = subject.parse('return "Hello World"')

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_a(Node::String)
        expect(ast.expression.value).to eq("Hello World")
      end

      it "parses return with comparison" do
        ast = subject.parse("return x > y")

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_a(Node::ComparisonOp)
        expect(ast.expression.op).to eq(:greater)
      end

      it "parses return without value (returns nil)" do
        ast = subject.parse("return")

        expect(ast).to be_a(Node::ReturnStatement)
        expect(ast.expression).to be_nil
      end
    end

    # STEP9新機能: 関数内での式の使用
    describe "functions in expressions" do
      it "parses function call in assignment" do
        ast = subject.parse("result = add(3, 4)")

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("result")
        expect(ast.value).to be_a(Node::FunctionCall)
        expect(ast.value.name).to eq("add")
      end

      it "parses function call in arithmetic expression" do
        ast = subject.parse("result = add(1, 2) * 3")

        expect(ast).to be_a(Node::Assignment)
        expect(ast.value).to be_a(Node::BinaryOp)
        expect(ast.value.op).to eq(:asterisk)
        expect(ast.value.lhs).to be_a(Node::FunctionCall)
        expect(ast.value.rhs).to be_a(Node::Integer)
        expect(ast.value.rhs.value).to eq(3)
      end

      it "parses function call in comparison" do
        ast = subject.parse("result = factorial(5) > 100")

        expect(ast).to be_a(Node::Assignment)
        expect(ast.value).to be_a(Node::ComparisonOp)
        expect(ast.value.op).to eq(:greater)
        expect(ast.value.lhs).to be_a(Node::FunctionCall)
        expect(ast.value.rhs).to be_a(Node::Integer)
      end

      it "parses function call in if condition" do
        ast = subject.parse("if < even?(n) > { hyouji(\"Even\") }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::FunctionCall)
        expect(ast.condition.name).to eq("even?")
      end

      it "parses function call in while condition" do
        ast = subject.parse("while < has_more?() > { process() }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::FunctionCall)
        expect(ast.condition.name).to eq("has_more?")
        expect(ast.body).to be_a(Node::FunctionCall)
        expect(ast.body.name).to eq("process")
      end

      it "parses function call in hyouji statement" do
        ast = subject.parse("hyouji(get_message())")

        expect(ast).to be_a(Node::HyoujiStatement)
        expect(ast.expression).to be_a(Node::FunctionCall)
        expect(ast.expression.name).to eq("get_message")
      end

      it "parses function call in string concatenation" do
        ast = subject.parse('result = "Value: " + get_value()')

        expect(ast).to be_a(Node::Assignment)
        expect(ast.value).to be_a(Node::BinaryOp)
        expect(ast.value.op).to eq(:plus)
        expect(ast.value.lhs).to be_a(Node::String)
        expect(ast.value.rhs).to be_a(Node::FunctionCall)
        expect(ast.value.rhs.name).to eq("get_value")
      end
    end

    # STEP9新機能: 複雑な関数構造のテスト
    describe "complex function scenarios" do
      it "parses recursive function definition" do
        ast = subject.parse("func factorial(n) { if < n =< 1 > { return 1 } else { return n * factorial(n - 1) } }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.name).to eq("factorial")
        expect(ast.parameters).to eq(["n"])
        expect(ast.body).to be_a(Node::IfStatement)

        # else節でfactorial関数を再帰呼び出ししている
        else_return = ast.body.else_body
        expect(else_return).to be_a(Node::ReturnStatement)
        multiply_expr = else_return.expression
        expect(multiply_expr).to be_a(Node::BinaryOp)
        expect(multiply_expr.op).to eq(:asterisk)
        expect(multiply_expr.rhs).to be_a(Node::FunctionCall)
        expect(multiply_expr.rhs.name).to eq("factorial")
      end

      it "parses function with multiple return paths" do
        ast = subject.parse("func max(a, b) { if < a > b > { return a } else { return b } }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.body).to be_a(Node::IfStatement)
        expect(ast.body.then_body).to be_a(Node::ReturnStatement)
        expect(ast.body.else_body).to be_a(Node::ReturnStatement)
      end

      it "parses function with early return" do
        ast = subject.parse("func validate(x) { if < x < 0 > { return false } hyouji(\"Valid\") return true }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.body).to be_a(Node::Block)
        expect(ast.body.statements).to have_attributes(size: 3)
        expect(ast.body.statements[0]).to be_a(Node::IfStatement)
        expect(ast.body.statements[1]).to be_a(Node::HyoujiStatement)
        expect(ast.body.statements[2]).to be_a(Node::ReturnStatement)
      end

      it "parses function calling other functions" do
        ast = subject.parse("func calculate(x, y) { return add(multiply(x, 2), y) }")

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.body).to be_a(Node::ReturnStatement)
        return_expr = ast.body.expression
        expect(return_expr).to be_a(Node::FunctionCall)
        expect(return_expr.name).to eq("add")
        expect(return_expr.arguments[0]).to be_a(Node::FunctionCall)
        expect(return_expr.arguments[0].name).to eq("multiply")
      end

      it "parses function with complex expressions" do
        ast = subject.parse('func greet(name, age) { return "Hello " + name + ", you are " + age + " years old" }')

        expect(ast).to be_a(Node::FunctionDef)
        expect(ast.parameters).to eq(["name", "age"])
        expect(ast.body).to be_a(Node::ReturnStatement)
        # 複数の文字列連結が含まれている
        expect(ast.body.expression).to be_a(Node::BinaryOp)
        expect(ast.body.expression.op).to eq(:plus)
      end
    end

    # STEP9新機能: エラーケースのテスト
    describe "function error handling" do
      it "raises error on malformed function definition" do
        expect { subject.parse("func") }.to raise_error(/Expected.*identifier/)
        expect { subject.parse("func test") }.to raise_error(/Expected/)
        expect { subject.parse("func test(") }.to raise_error(/Expected.*identifier/)
        expect { subject.parse("func test()") }.to raise_error(/Expected/)
        expect { subject.parse("func test() {") }.to raise_error(/Expected/)
      end

      it "raises error on malformed parameter list" do
        expect { subject.parse("func test(,)") }.to raise_error(/Expected/)
        expect { subject.parse("func test(a,)") }.to raise_error(/Expected/)
        expect { subject.parse("func test(,b)") }.to raise_error(/Expected/)
        expect { subject.parse("func test(a,,b)") }.to raise_error(/Expected/)
      end

      it "raises error on malformed function call" do
        expect { subject.parse("test(") }.to raise_error(/Unexpected/)
        expect { subject.parse("test)") }.to raise_error(/Unexpected/)
        expect { subject.parse("test(,)") }.to raise_error(/Unexpected/)
        expect { subject.parse("test(1,)") }.to raise_error(/Unexpected/)
        expect { subject.parse("test(,2)") }.to raise_error(/Unexpected/)
      end

      it "raises error on invalid return statements" do
        expect { subject.parse("return +") }.to raise_error(/Unexpected/)
        expect { subject.parse("return * 2") }.to raise_error(/Unexpected/)
      end

      it "raises error on invalid function names" do
        expect { subject.parse("func 123() { }") }.to raise_error(/Expected/)
        expect { subject.parse("func + () { }") }.to raise_error(/Expected/)
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
