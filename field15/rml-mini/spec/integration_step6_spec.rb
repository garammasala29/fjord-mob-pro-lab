# spec/integration_step6_spec.rb
require_relative "../lib/parser_step6"
require_relative "../lib/evaluator"

RSpec.describe "Integration Step6" do
  let(:parser) { ParserStep6 }
  let(:evaluator) { Evaluator.new }

  def evaluate(input)
    ast = parser.parse(input)
    evaluator.evaluate(ast)
  end

  # Step5からの継承テスト
  describe "variable assignment and reference (from Step5)" do
    it "変数代入と参照を正しく処理する" do
      expect(evaluate("x = 10")).to eq(10)
      expect(evaluate("x")).to eq(10)
      expect(evaluate("x + 5")).to eq(15)
      expect(evaluate("y = x * 2")).to eq(20)
      expect(evaluate("y")).to eq(20)
    end

    it "未定義の変数でエラーを発生させる" do
      expect { evaluate("z") }.to raise_error(/未定義の変数/)
    end
  end

  # Step4からの継承テスト
  describe "arithmetic operations (from Step4)" do
    it "correctly evaluates basic expressions" do
      expect(evaluate("1 + 2")).to eq(3)
      expect(evaluate("5 - 3")).to eq(2)
      expect(evaluate("3 * 4")).to eq(12)
      expect(evaluate("10 / 2")).to eq(5)
    end

    it "correctly handles operator precedence" do
      expect(evaluate("2 + 3 * 4")).to eq(14)
      expect(evaluate("10 - 4 / 2")).to eq(8)
    end

    it "correctly evaluates expressions with parentheses" do
      expect(evaluate("(2 + 3) * 4")).to eq(20)
      expect(evaluate("2 * (3 + 4)")).to eq(14)
      expect(evaluate("(8 - 4) / (1 + 1)")).to eq(2)
    end
  end

  # Step6新機能: Boolean型
  describe "boolean literals" do
    it "evaluates true and false" do
      expect(evaluate("true")).to eq(true)
      expect(evaluate("false")).to eq(false)
    end

    it "assigns boolean to variables" do
      expect(evaluate("flag = true")).to eq(true)
      expect(evaluate("flag")).to eq(true)

      expect(evaluate("is_done = false")).to eq(false)
      expect(evaluate("is_done")).to eq(false)
    end
  end

  # Step6新機能: 比較演算子
  describe "comparison operators" do
    it "evaluates equality ==" do
      expect(evaluate("5 == 5")).to eq(true)
      expect(evaluate("5 == 3")).to eq(false)
      expect(evaluate("true == true")).to eq(true)
      expect(evaluate("true == false")).to eq(false)
    end

    it "evaluates inequality !=" do
      expect(evaluate("5 != 3")).to eq(true)
      expect(evaluate("5 != 5")).to eq(false)
      expect(evaluate("true != false")).to eq(true)
    end

    it "evaluates less than <" do
      expect(evaluate("3 < 5")).to eq(true)
      expect(evaluate("5 < 3")).to eq(false)
      expect(evaluate("5 < 5")).to eq(false)
    end

    it "evaluates greater than >" do
      expect(evaluate("5 > 3")).to eq(true)
      expect(evaluate("3 > 5")).to eq(false)
      expect(evaluate("5 > 5")).to eq(false)
    end

    it "evaluates less than or equal =< (custom syntax)" do
      expect(evaluate("3 =< 5")).to eq(true)
      expect(evaluate("5 =< 5")).to eq(true)
      expect(evaluate("5 =< 3")).to eq(false)
    end

    it "evaluates greater than or equal => (custom syntax)" do
      expect(evaluate("5 => 3")).to eq(true)
      expect(evaluate("5 => 5")).to eq(true)
      expect(evaluate("3 => 5")).to eq(false)
    end
  end

  # Step6新機能: 比較演算子と算術演算子の組み合わせ
  describe "comparison with arithmetic expressions" do
    it "compares arithmetic expressions" do
      expect(evaluate("2 + 3 == 5")).to eq(true)
      expect(evaluate("2 * 3 > 5")).to eq(true)
      expect(evaluate("10 / 2 =< 4")).to eq(false)
      expect(evaluate("4 + 1 => 3 * 2")).to eq(false)
    end

    it "compares variables" do
      evaluate("x = 10")
      evaluate("y = 5")

      expect(evaluate("x > y")).to eq(true)
      expect(evaluate("x == y * 2")).to eq(true)
      expect(evaluate("x + y => 20")).to eq(false)
      expect(evaluate("x - y =< 6")).to eq(true)
    end

    it "assigns comparison results to variables" do
      expect(evaluate("result = 5 > 3")).to eq(true)
      expect(evaluate("result")).to eq(true)

      expect(evaluate("is_equal = 10 == 5 * 2")).to eq(true)
      expect(evaluate("is_equal")).to eq(true)
    end
  end

  # Step6新機能: if文
  describe "if statements" do
    it "executes then branch when condition is true" do
      result = evaluate("if < true > { x = 42 }")
      expect(result).to eq(42)
      expect(evaluate("x")).to eq(42)
    end

    it "returns nil when condition is false and no else" do
      result = evaluate("if < false > { x = 42 }")
      expect(result).to be_nil
    end

    it "executes else branch when condition is false" do
      result = evaluate("if < false > { x = 42 } else { x = 24 }")
      expect(result).to eq(24)
      expect(evaluate("x")).to eq(24)
    end

    it "works with comparison conditions" do
      evaluate("score = 85")
      result = evaluate("if < score > 80 > { grade = 1 } else { grade = 0 }")
      expect(result).to eq(1)
      expect(evaluate("grade")).to eq(1)
    end

    it "works with complex comparison conditions" do
      evaluate("a = 5")
      evaluate("b = 10")
      result = evaluate("if < a + b == 15 > { result = 1 } else { result = 0 }")
      expect(result).to eq(1)
      expect(evaluate("result")).to eq(1)
    end

    it "executes else-if branch" do
      evaluate("score = 85")
      result = evaluate("if < score => 90 > { grade = 4 } else-if < score => 80 > { grade = 3 } else-if < score => 70 > { grade = 2 } else { grade = 1 }")
      expect(result).to eq(3)
      expect(evaluate("grade")).to eq(3)
    end

    it "executes multiple else-if branches correctly" do
      evaluate("score = 75")
      result = evaluate("if < score => 90 > { grade = 4 } else-if < score => 80 > { grade = 3 } else-if < score => 70 > { grade = 2 } else { grade = 1 }")
      expect(result).to eq(2)
      expect(evaluate("grade")).to eq(2)
    end

    it "executes else when no conditions match" do
      evaluate("score = 65")
      result = evaluate("if < score => 90 > { grade = 4 } else-if < score => 80 > { grade = 3 } else-if < score => 70 > { grade = 2 } else { grade = 1 }")
      expect(result).to eq(1)
      expect(evaluate("grade")).to eq(1)
    end

    it "handles multiple statements in if blocks" do
      result = evaluate("if < true > { x = 10 y = 20 }")
      expect(result).to eq(20) # 最後のstatementの結果
      expect(evaluate("x")).to eq(10)
      expect(evaluate("y")).to eq(20)
    end

    it "handles nested expressions in conditions" do
      evaluate("x = 10")
      result = evaluate("if < (x * 2) > 15 > { result = 1 } else { result = 0 }")
      expect(result).to eq(1)
    end
  end

  # 演算子の優先順位テスト
  describe "operator precedence" do
    it "arithmetic has higher precedence than comparison" do
      # 2 + 3 == 5 should be parsed as (2 + 3) == 5, not 2 + (3 == 5)
      expect(evaluate("2 + 3 == 5")).to eq(true)
      expect(evaluate("2 * 3 > 5")).to eq(true)
      expect(evaluate("10 / 2 + 1 =< 6")).to eq(true)
    end

    it "parentheses override precedence" do
      expect(evaluate("(5 > 3) == true")).to eq(true)
      expect(evaluate("(2 + 3) == (4 + 1)")).to eq(true)
    end
  end

  # 実用的な例
  describe "practical examples" do
    it "absolute value calculation" do
      # これは負の数実装したら動かそう
      # evaluate("num = -15")
      # result = evaluate("if < num => 0 > { abs_value = num } else { abs_value = 0 - num }")
      # expect(result).to eq(15)
      # expect(evaluate("abs_value")).to eq(15)

      # 正の数でも試す
      evaluate("num2 = 10")
      result = evaluate("if < num2 => 0 > { abs_value2 = num2 } else { abs_value2 = 0 - num2 }")
      expect(result).to eq(10)
      expect(evaluate("abs_value2")).to eq(10)
    end

    it "maximum of two numbers" do
      evaluate("first = 25")
      evaluate("second = 30")
      result = evaluate("if < first > second > { max = first } else { max = second }")
      expect(result).to eq(30)
      expect(evaluate("max")).to eq(30)
    end

    it "grade calculation system" do
      evaluate("score = 87")
      result = evaluate("if < score => 90 > { grade = 4 message = 1 } else-if < score => 80 > { grade = 3 message = 2 } else-if < score => 70 > { grade = 2 message = 3 } else { grade = 1 message = 4 }")
      expect(result).to eq(2)
      expect(evaluate("grade")).to eq(3)
      expect(evaluate("message")).to eq(2)
    end
  end

  # エラーケース
  describe "error handling" do
    it "raises error when if condition is not boolean" do
      expect { evaluate("if < 42 > { x = 1 }") }.to raise_error(/The condition of an if statement must be a boolean/)
    end

    it "raises error when else-if condition is not boolean" do
      expect {
        evaluate("if < false > { x = 1 } else-if < 42 > { x = 2 }")
      }.to raise_error(/The condition of an if statement must be a boolean/)
    end

    it "raises syntax error for malformed if statement" do
      expect { evaluate("if true { x = 1 }") }.to raise_error(/Expected/)
      expect { evaluate("if < true { x = 1 }") }.to raise_error(/Expected/)
      expect { evaluate("if < true > x = 1 }") }.to raise_error(/Expected/)
    end
  end
end
