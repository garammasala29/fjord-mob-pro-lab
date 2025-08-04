# spec/parser_step7_spec.rb
require_relative "../lib/parser_step7"
require_relative "../lib/node"

RSpec.describe ParserStep7 do
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

    # 比較演算子のテスト
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

      it "parses inequality !=" do
        ast = subject.parse("5 != 3")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:not_equal)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(5)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(3)
      end

      it "parses less than <" do
        ast = subject.parse("3 < 5")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:less)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(3)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(5)
      end

      it "parses greater than >" do
        ast = subject.parse("5 > 3")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:greater)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(5)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(3)
      end

      it "parses less than or equal =< (custom syntax)" do
        ast = subject.parse("3 =< 5")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_less)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(3)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(5)
      end

      it "parses greater than or equal => (custom syntax)" do
        ast = subject.parse("5 => 3")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_greater)
        expect(ast.lhs).to be_a(Node::Integer)
        expect(ast.lhs.value).to eq(5)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(3)
      end

      it "parses comparison with variables" do
        ast = subject.parse("x > y")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:greater)
        expect(ast.lhs).to be_a(Node::Variable)
        expect(ast.lhs.name).to eq("x")
        expect(ast.rhs).to be_a(Node::Variable)
        expect(ast.rhs.name).to eq("y")
      end

      it "parses comparison assignment" do
        ast = subject.parse("result = 5 > 3")

        expect(ast).to be_a(Node::Assignment)
        expect(ast.name).to eq("result")
        expect(ast.value).to be_a(Node::ComparisonOp)
        expect(ast.value.op).to eq(:greater)
      end
    end

    # 演算子優先順位テスト
    describe "operator precedence" do
      it "arithmetic has higher precedence than comparison" do
        # 2 + 3 == 5 should be parsed as (2 + 3) == 5
        ast = subject.parse("2 + 3 == 5")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_equal)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:plus)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(5)
      end

      it "multiplication has higher precedence than comparison" do
        # 2 * 3 > 5 should be parsed as (2 * 3) > 5
        ast = subject.parse("2 * 3 > 5")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:greater)
        expect(ast.lhs).to be_a(Node::BinaryOp)
        expect(ast.lhs.op).to eq(:asterisk)
        expect(ast.rhs).to be_a(Node::Integer)
        expect(ast.rhs.value).to eq(5)
      end

      it "parentheses override precedence" do
        ast = subject.parse("(5 > 3) == true")

        expect(ast).to be_a(Node::ComparisonOp)
        expect(ast.op).to eq(:equal_equal)
        expect(ast.lhs).to be_a(Node::ComparisonOp)
        expect(ast.lhs.op).to eq(:greater)
        expect(ast.rhs).to be_a(Node::Boolean)
        expect(ast.rhs.value).to eq(true)
      end
    end

    # if文のテスト
    describe "if statements" do
      it "parses simple if statement" do
        ast = subject.parse("if < true > { x = 42 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::Boolean)
        expect(ast.condition.value).to eq(true)
        expect(ast.then_body).to be_a(Node::Assignment)
        expect(ast.then_body.name).to eq("x")
        expect(ast.else_ifs).to be_empty
        expect(ast.else_body).to be_nil
      end

      it "parses if-else statement" do
        ast = subject.parse("if < false > { x = 42 } else { x = 24 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::Boolean)
        expect(ast.condition.value).to eq(false)
        expect(ast.then_body).to be_a(Node::Assignment)
        expect(ast.else_body).to be_a(Node::Assignment)
        expect(ast.else_body.name).to eq("x")
        expect(ast.else_body.value.value).to eq(24)
      end

      it "parses if with comparison condition" do
        ast = subject.parse("if < x > 5 > { result = 1 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:greater)
        expect(ast.condition.lhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.name).to eq("x")
        expect(ast.condition.rhs).to be_a(Node::Integer)
        expect(ast.condition.rhs.value).to eq(5)
      end

      it "parses if-else-if statement" do
        ast = subject.parse("if < score => 90 > { grade = 4 } else-if < score => 80 > { grade = 3 } else { grade = 1 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)

        expect(ast.else_ifs).to have_attributes(size: 1)
        else_if = ast.else_ifs.first
        expect(else_if.condition).to be_a(Node::ComparisonOp)
        expect(else_if.condition.op).to eq(:equal_greater)
        expect(else_if.body).to be_a(Node::Assignment)
        expect(else_if.body.name).to eq("grade")
        expect(else_if.body.value.value).to eq(3)

        expect(ast.else_body).to be_a(Node::Assignment)
        expect(ast.else_body.name).to eq("grade")
        expect(ast.else_body.value.value).to eq(1)
      end

      it "parses multiple else-if statements" do
        ast = subject.parse("if < a > { x = 1 } else-if < b > { x = 2 } else-if < c > { x = 3 } else { x = 4 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.else_ifs).to have_attributes(size: 2)

        first_elsif = ast.else_ifs[0]
        expect(first_elsif.condition).to be_a(Node::Variable)
        expect(first_elsif.condition.name).to eq("b")

        second_elsif = ast.else_ifs[1]
        expect(second_elsif.condition).to be_a(Node::Variable)
        expect(second_elsif.condition.name).to eq("c")
      end

      it "parses if with multiple statements in then block" do
        ast = subject.parse("if < true > { x = 10 y = 20 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.then_body).to be_a(Node::Block)
        expect(ast.then_body.statements).to have_attributes(size: 2)

        first_stmt = ast.then_body.statements[0]
        expect(first_stmt).to be_a(Node::Assignment)
        expect(first_stmt.name).to eq("x")

        second_stmt = ast.then_body.statements[1]
        expect(second_stmt).to be_a(Node::Assignment)
        expect(second_stmt.name).to eq("y")
      end

      it "parses if with complex condition" do
        ast = subject.parse("if < (a + b) == (c * d) > { result = 1 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:equal_equal)
        expect(ast.condition.lhs).to be_a(Node::BinaryOp)
        expect(ast.condition.lhs.op).to eq(:plus)
        expect(ast.condition.rhs).to be_a(Node::BinaryOp)
        expect(ast.condition.rhs.op).to eq(:asterisk)
      end
    end

    # STEP7新機能: while文のテスト
    describe "while statements" do
      it "parses simple while statement" do
        ast = subject.parse("while < x > 0 > { x = x - 1 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:greater)
        expect(ast.condition.lhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.name).to eq("x")
        expect(ast.condition.rhs).to be_a(Node::Integer)
        expect(ast.condition.rhs.value).to eq(0)
        expect(ast.body).to be_a(Node::Assignment)
        expect(ast.body.name).to eq("x")
      end

      it "parses while with boolean condition" do
        ast = subject.parse("while < flag == true > { counter = counter + 1 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:equal_equal)
        expect(ast.condition.lhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.name).to eq("flag")
        expect(ast.condition.rhs).to be_a(Node::Boolean)
        expect(ast.condition.rhs.value).to eq(true)
        expect(ast.body).to be_a(Node::Assignment)
        expect(ast.body.name).to eq("counter")
      end

      it "parses while with complex condition" do
        ast = subject.parse("while < (x + y) =< 10 > { result = result * 2 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:equal_less)
        expect(ast.condition.lhs).to be_a(Node::BinaryOp)
        expect(ast.condition.lhs.op).to eq(:plus)
        expect(ast.condition.lhs.lhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.lhs.name).to eq("x")
        expect(ast.condition.lhs.rhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.rhs.name).to eq("y")
        expect(ast.condition.rhs).to be_a(Node::Integer)
        expect(ast.condition.rhs.value).to eq(10)
      end

      it "parses while with multiple statements in body" do
        ast = subject.parse("while < i =< n > { factorial = factorial * i i = i + 1 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:equal_less)
        expect(ast.body).to be_a(Node::Block)
        expect(ast.body.statements).to have_attributes(size: 2)

        first_stmt = ast.body.statements[0]
        expect(first_stmt).to be_a(Node::Assignment)
        expect(first_stmt.name).to eq("factorial")

        second_stmt = ast.body.statements[1]
        expect(first_stmt).to be_a(Node::Assignment)
        expect(second_stmt.name).to eq("i")
      end

      it "parses while with boolean literal condition" do
        ast = subject.parse("while < true > { break_flag = false }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::Boolean)
        expect(ast.condition.value).to eq(true)
        expect(ast.body).to be_a(Node::Assignment)
        expect(ast.body.name).to eq("break_flag")
        expect(ast.body.value).to be_a(Node::Boolean)
        expect(ast.body.value.value).to eq(false)
      end

      it "parses while with variable condition" do
        ast = subject.parse("while < running > { process_item = true }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::Variable)
        expect(ast.condition.name).to eq("running")
        expect(ast.body).to be_a(Node::Assignment)
      end

      it "parses nested control structures - if inside while" do
        ast = subject.parse("while < x > 0 > { if < x == 5 > { break_flag = true } x = x - 1 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.body).to be_a(Node::Block)
        expect(ast.body.statements).to have_attributes(size: 2)

        nested_if = ast.body.statements[0]
        expect(nested_if).to be_a(Node::IfStatement)
        expect(nested_if.condition).to be_a(Node::ComparisonOp)
        expect(nested_if.condition.op).to eq(:equal_equal)

        loop_decrement = ast.body.statements[1]
        expect(loop_decrement).to be_a(Node::Assignment)
        expect(loop_decrement.name).to eq("x")
      end

      it "parses while with custom comparison operators" do
        ast = subject.parse("while < i =< max_count > { count = count + 1 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.condition).to be_a(Node::ComparisonOp)
        expect(ast.condition.op).to eq(:equal_less)
        expect(ast.condition.lhs).to be_a(Node::Variable)
        expect(ast.condition.lhs.name).to eq("i")
        expect(ast.condition.rhs).to be_a(Node::Variable)
        expect(ast.condition.rhs.name).to eq("max_count")
      end
    end

    # 制御構造の組み合わせテスト
    describe "combined control structures" do
      it "parses if-else with while in branches" do
        ast = subject.parse("if < mode == 1 > { while < x > 0 > { x = x - 1 } } else { y = 10 }")

        expect(ast).to be_a(Node::IfStatement)
        expect(ast.then_body).to be_a(Node::WhileStatement)
        expect(ast.then_body.condition).to be_a(Node::ComparisonOp)
        expect(ast.then_body.condition.op).to eq(:greater)
        expect(ast.else_body).to be_a(Node::Assignment)
        expect(ast.else_body.name).to eq("y")
      end

      it "parses multiple nested while loops" do
        ast = subject.parse("while < outer > 0 > { while < inner > 0 > { inner = inner - 1 } outer = outer - 1 }")

        expect(ast).to be_a(Node::WhileStatement)
        expect(ast.body).to be_a(Node::Block)
        expect(ast.body.statements).to have_attributes(size: 2)

        nested_while = ast.body.statements[0]
        expect(nested_while).to be_a(Node::WhileStatement)
        expect(nested_while.condition).to be_a(Node::ComparisonOp)
        expect(nested_while.condition.lhs).to be_a(Node::Variable)
        expect(nested_while.condition.lhs.name).to eq("inner")

        outer_decrement = ast.body.statements[1]
        expect(outer_decrement).to be_a(Node::Assignment)
        expect(outer_decrement.name).to eq("outer")
      end
    end

    # エラーケース
    describe "error handling" do
      it "raises error on unbalanced parentheses" do
        expect { subject.parse("(2 + 3") }.to raise_error(RuntimeError)
        expect { subject.parse("2 + 3)") }.to raise_error(RuntimeError)
      end

      it "raises error on malformed if statement" do
        expect { subject.parse("if true { x = 1 }") }.to raise_error(/Expected/)
        expect { subject.parse("if < true { x = 1 }") }.to raise_error(/Expected/)
        expect { subject.parse("if < true > x = 1 }") }.to raise_error(/Expected/)
        expect { subject.parse("if < true > { x = 1") }.to raise_error(/Expected/)
      end

      it "raises error on malformed else-if" do
        expect { subject.parse("if < true > { x = 1 } else-if true { x = 2 }") }.to raise_error(/Expected/)
        expect { subject.parse("if < true > { x = 1 } else-if < true { x = 2 }") }.to raise_error(/Expected/)
      end

      # STEP7: while文のエラーケース
      it "raises error on malformed while statement" do
        expect { subject.parse("while true { x = 1 }") }.to raise_error(/Expected/)
        expect { subject.parse("while < true { x = 1 }") }.to raise_error(/Expected/)
        expect { subject.parse("while < true > x = 1 }") }.to raise_error(/Expected/)
        expect { subject.parse("while < true > { x = 1") }.to raise_error(/Expected/)
      end

      it "raises error on while without condition" do
        expect { subject.parse("while < > { x = 1 }") }.to raise_error(/Unexpected/)
        expect { subject.parse("while { x = 1 }") }.to raise_error(/Expected/)
      end

      it "raises error on while without body" do
        expect { subject.parse("while < true >") }.to raise_error(/Unexpected/)
        expect { subject.parse("while < x > 0 >") }.to raise_error(/Unexpected/)
      end

      it "raises error on unexpected tokens" do
        expect { subject.parse("5 + + 3") }.to raise_error(/Unexpected/)
        expect { subject.parse("if < > { x = 1 }") }.to raise_error(/Unexpected/)
        expect { subject.parse("while < > { x = 1 }") }.to raise_error(/Unexpected/)
      end

      it "raises error on incomplete expressions" do
        expect { subject.parse("5 +") }.to raise_error(/Unexpected/)
        expect { subject.parse("x =") }.to raise_error(/Unexpected/)
        expect { subject.parse("5 ==") }.to raise_error(/Unexpected/)
        expect { subject.parse("while <") }.to raise_error(/Unexpected/)
      end
    end
  end
end
