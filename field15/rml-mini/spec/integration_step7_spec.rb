# spec/integration_step7_spec.rb
require_relative "../lib/parser_step7"
require_relative "../lib/evaluator"

RSpec.describe "Integration Step7" do
  let(:parser) { ParserStep7 }
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

  # Boolean型のテスト
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

  # 比較演算子のテスト
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

  # 比較演算子と算術演算子の組み合わせ
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

  # if文のテスト
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

  # STEP7新機能: while文のテスト
  describe "while statements" do
    it "executes simple counting loop" do
      evaluate("counter = 0")
      result = evaluate("while < counter < 5 > { counter = counter + 1 }")
      expect(result).to eq(5)
      expect(evaluate("counter")).to eq(5)
    end

    it "calculates factorial using while loop" do
      evaluate("n = 5")
      evaluate("factorial = 1")
      evaluate("i = 1")
      result = evaluate("while < i =< n > { factorial = factorial * i i = i + 1 }")
      expect(result).to eq(6) # 最後の i = i + 1 の結果
      expect(evaluate("factorial")).to eq(120) # 5!
      expect(evaluate("i")).to eq(6)
    end

    it "calculates sum using while loop" do
      evaluate("n = 10")
      evaluate("sum = 0")
      evaluate("i = 1")
      result = evaluate("while < i =< n > { sum = sum + i i = i + 1 }")
      expect(result).to eq(11) # 最後の i = i + 1 の結果
      expect(evaluate("sum")).to eq(55) # 1+2+...+10
      expect(evaluate("i")).to eq(11)
    end

    it "returns nil when condition is false initially" do
      evaluate("flag = false")
      result = evaluate("while < flag > { x = 42 }")
      expect(result).to be_nil
    end

    it "works with boolean variable conditions" do
      evaluate("running = true")
      evaluate("count = 0")
      result = evaluate("while < running > { count = count + 1 running = count < 3 }")
      expect(result).to eq(false) # 最後の running = count < 3 の結果
      expect(evaluate("count")).to eq(3)
      expect(evaluate("running")).to eq(false)
    end

    it "works with complex arithmetic conditions" do
      evaluate("x = 100")
      evaluate("steps = 0")
      result = evaluate("while < x > 1 > { if < (x / 2) * 2 == x > { x = x / 2 } else { x = x * 3 + 1 } steps = steps + 1 }")
      # コラッツ予想のステップ数計算
      expect(evaluate("x")).to eq(1)
      expect(evaluate("steps")).to be > 0
    end

    it "handles nested while loops" do
      evaluate("outer = 3")
      evaluate("total = 0")
      result = evaluate("while < outer > 0 > { inner = 2 while < inner > 0 > { total = total + 1 inner = inner - 1 } outer = outer - 1 }")
      expect(result).to eq(0) # 最後の outer = outer - 1 の結果
      expect(evaluate("total")).to eq(6) # 3 * 2 = 6
      expect(evaluate("outer")).to eq(0)
    end

    it "combines while with if statements" do
      evaluate("numbers = 10")
      evaluate("even_count = 0")
      evaluate("odd_count = 0")
      result = evaluate("while < numbers > 0 > { if < (numbers / 2) * 2 == numbers > { even_count = even_count + 1 } else { odd_count = odd_count + 1 } numbers = numbers - 1 }")
      expect(result).to eq(0) # 最後の numbers = numbers - 1 の結果
      expect(evaluate("numbers")).to eq(0)
      expect(evaluate("even_count")).to eq(5) # 2,4,6,8,10
      expect(evaluate("odd_count")).to eq(5) # 1,3,5,7,9
    end

    it "handles while with complex conditions" do
      evaluate("a = 20")
      evaluate("b = 15")
      evaluate("iterations = 0")
      result = evaluate("while < (a + b) > 30 > { a = a - 1 b = b - 1 iterations = iterations + 1 }")
      expect(result).to eq(3) # 最後の iterations = iterations + 1 の結果 (a+b: 35->33->31->29で3回実行)
      expect(evaluate("a")).to eq(17) # 20-3=17
      expect(evaluate("b")).to eq(12) # 15-3=12
      expect(evaluate("iterations")).to eq(3)
    end
  end

  # 制御構造の組み合わせテスト
  describe "combined control structures" do
    it "while inside if statement" do
      evaluate("mode = 1")
      evaluate("result = 0")
      result = evaluate("if < mode == 1 > { counter = 0 while < counter < 3 > { result = result + counter counter = counter + 1 } } else { result = 100 }")
      expect(result).to eq(3) # 最後の counter = counter + 1 の結果
      expect(evaluate("result")).to eq(3) # 0 + 1 + 2 = 3
    end

    it "if inside while statement" do
      evaluate("i = 1")
      evaluate("sum_even = 0")
      evaluate("sum_odd = 0")
      result = evaluate("while < i =< 10 > { if < (i / 2) * 2 == i > { sum_even = sum_even + i } else { sum_odd = sum_odd + i } i = i + 1 }")
      expect(result).to eq(11) # 最後の i = i + 1 の結果
      expect(evaluate("sum_even")).to eq(30) # 2+4+6+8+10
      expect(evaluate("sum_odd")).to eq(25) # 1+3+5+7+9
    end

    it "nested if-else inside while" do
      evaluate("score = 95")
      evaluate("bonus = 0")
      evaluate("penalty = 0")
      result = evaluate("while < score > 70 > { if < score => 90 > { bonus = bonus + 10 } else-if < score => 80 > { bonus = bonus + 5 } else { penalty = penalty + 1 } score = score - 10 }")
      expect(result).to eq(65) # 最後の score = score - 10 の結果
      expect(evaluate("bonus")).to eq(15) # 10 (for 95) + 5 (for 85)
      expect(evaluate("penalty")).to eq(1) # for 75
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

    it "parentheses override precedence in while conditions" do
      evaluate("x = 10")
      evaluate("y = 5")
      result = evaluate("while < (x - y) > 2 > { x = x - 1 }")
      expect(result).to eq(7) # 最後の x = x - 1 の結果
      expect(evaluate("x")).to eq(7)
    end
  end

  # 実用的な例
  describe "practical examples" do
    it "finds greatest common divisor (GCD) using while" do
      evaluate("a = 48")
      evaluate("b = 18")
      result = evaluate("while < b != 0 > { temp = b b = a - (a / b) * b a = temp }")
      # ユークリッドの互除法
      expect(evaluate("a")).to eq(6) # GCD(48, 18) = 6
    end

    it "power calculation using while loop" do
      evaluate("base = 2")
      evaluate("exponent = 8")
      evaluate("result = 1")
      result = evaluate("while < exponent > 0 > { result = result * base exponent = exponent - 1 }")
      expect(result).to eq(0) # 最後の exponent = exponent - 1 の結果
      expect(evaluate("result")).to eq(256) # 2^8
    end

    it "fibonacci sequence using while" do
      evaluate("n = 10")
      evaluate("first = 0")
      evaluate("second = 1")
      evaluate("count = 2")
      result = evaluate("while < count < n > { next_fib = first + second first = second second = next_fib count = count + 1 }")
      expect(result).to eq(10) # 最後の count = count + 1 の結果
      expect(evaluate("second")).to eq(34) # 10番目のフィボナッチ数
    end

    it "absolute value calculation with while (simulating abs)" do
      evaluate("num = 10")
      evaluate("abs_value = num")
      result = evaluate("while < abs_value < 0 > { abs_value = 0 - abs_value }")
      expect(result).to be_nil # ループが実行されない
      expect(evaluate("abs_value")).to eq(10)
    end

    it "digital root calculation" do
      evaluate("number = 9875")
      evaluate("digital_root = number")
      result = evaluate("while < digital_root => 10 > { sum = 0 temp = digital_root while < temp > 0 > { sum = sum + (temp - (temp / 10) * 10) temp = temp / 10 } digital_root = sum }")
      expect(evaluate("digital_root")).to be_between(1, 9) # デジタルルートは1-9
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
      }.to raise_error(/The condition of an else-if statement must be a boolean/)
    end

    it "raises error when while condition is not boolean" do
      expect { evaluate("while < 42 > { x = 1 }") }.to raise_error(/The condition of a while statement must be a boolean/)
    end

    it "prevents infinite loops" do
      expect { evaluate("while < true > { x = 1 }") }.to raise_error(/Loop exceeded maximum iterations.*Possible infinite loop detected/)
    end

    it "raises syntax error for malformed while statement" do
      expect { evaluate("while true { x = 1 }") }.to raise_error(/Expected/)
      expect { evaluate("while < true { x = 1 }") }.to raise_error(/Expected/)
      expect { evaluate("while < true > x = 1 }") }.to raise_error(/Expected/)
    end

    it "raises syntax error for malformed if statement" do
      expect { evaluate("if true { x = 1 }") }.to raise_error(/Expected/)
      expect { evaluate("if < true { x = 1 }") }.to raise_error(/Expected/)
      expect { evaluate("if < true > x = 1 }") }.to raise_error(/Expected/)
    end
  end
end
