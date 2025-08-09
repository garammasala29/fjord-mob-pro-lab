# spec/integration_step8_spec.rb
require_relative "../lib/parser_step8"
require_relative "../lib/evaluator"

RSpec.describe "Integration Step8" do
  let(:parser) { ParserStep8 }
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

  # STEP8新機能: 文字列のテスト
  describe "string literals and operations" do
    it "evaluates string literals" do
      expect(evaluate('"Hello"')).to eq("Hello")
      expect(evaluate("'World'")).to eq("World")
      expect(evaluate('""')).to eq("")
    end

    it "assigns strings to variables" do
      expect(evaluate('message = "Hello World"')).to eq("Hello World")
      expect(evaluate("message")).to eq("Hello World")
    end

    it "concatenates strings" do
      expect(evaluate('"Hello " + "World"')).to eq("Hello World")
      expect(evaluate('"Count: " + 42')).to eq("Count: 42")
      expect(evaluate('42 + " items"')).to eq("42 items")
    end

    it "concatenates with boolean values" do
      expect(evaluate('"Result: " + true')).to eq("Result: true")
      expect(evaluate('false + " value"')).to eq("false value")
    end

    it "concatenates complex expressions" do
      evaluate("x = 5")
      evaluate("y = 3")
      expect(evaluate('"Sum: " + (x + y)')).to eq("Sum: 8")
      expect(evaluate('"Product: " + x * y')).to eq("Product: 15")
    end

    it "handles multiple string concatenations" do
      evaluate('name = "Alice"')
      expect(evaluate('"Hello " + name + "!"')).to eq("Hello Alice!")
      expect(evaluate('"The value " + 42 + " is good"')).to eq("The value 42 is good")
    end

    it "works with escape sequences" do
      expect(evaluate('"Line 1\\nLine 2"')).to eq("Line 1\nLine 2")
      expect(evaluate('"Quote: \\"Hello\\""')).to eq('Quote: "Hello"')
    end
  end

  # STEP8新機能: hyouji文のテスト
  describe "hyouji statements" do
    it "outputs simple values" do
      expect { evaluate('hyouji("Hello World")') }.to output("Hello World\n").to_stdout
      expect { evaluate('hyouji(42)') }.to output("42\n").to_stdout
      expect { evaluate('hyouji(true)') }.to output("true\n").to_stdout
    end

    it "outputs variables" do
      evaluate('message = "Hello"')
      expect { evaluate('hyouji(message)') }.to output("Hello\n").to_stdout
    end

    it "outputs string concatenation results" do
      evaluate('name = "Alice"')
      expect { evaluate('hyouji("Hello " + name)') }.to output("Hello Alice\n").to_stdout
    end

    it "outputs arithmetic results" do
      expect { evaluate('hyouji(5 + 3)') }.to output("8\n").to_stdout
    end

    it "outputs comparison results" do
      expect { evaluate('hyouji(5 > 3)') }.to output("true\n").to_stdout
    end

    it "returns nil" do
      expect(evaluate('hyouji("test")')).to be_nil
    end
  end

  # 比較演算子のテスト（文字列込み）
  describe "comparison operators with strings" do
    it "compares strings" do
      expect(evaluate('"hello" == "hello"')).to eq(true)
      expect(evaluate('"hello" == "world"')).to eq(false)
      expect(evaluate('"hello" != "world"')).to eq(true)
    end

    it "compares string variables" do
      evaluate('name1 = "Alice"')
      evaluate('name2 = "Bob"')
      expect(evaluate("name1 == name2")).to eq(false)
      expect(evaluate("name1 != name2")).to eq(true)
    end

    it "compares strings with other types" do
      expect(evaluate('"42" == 42')).to eq(false)  # 型が違うのでfalse
      expect(evaluate('"true" == true')).to eq(false)
    end
  end

  # 演算子優先順位テスト（文字列込み）
  describe "operator precedence with strings" do
    it "string concatenation has same precedence as addition" do
      expect(evaluate('"a" + "b" + "c"')).to eq("abc")
    end

    it "arithmetic has higher precedence than string concatenation" do
      expect(evaluate('"Count: " + 2 * 3')).to eq("Count: 6")
    end

    it "comparison has lower precedence than string concatenation" do
      expect(evaluate('"a" + "b" == "ab"')).to eq(true)
    end
  end

  # if文のテスト（文字列込み）
  describe "if statements with strings" do
    it "uses string comparison in conditions" do
      evaluate('name = "Alice"')
      result = evaluate('if < name == "Alice" > { greeting = "Hello Alice" } else { greeting = "Hello stranger" }')
      expect(result).to eq("Hello Alice")
      expect(evaluate("greeting")).to eq("Hello Alice")
    end

    it "assigns strings in if branches" do
      evaluate("score = 85")
      result = evaluate('if < score => 90 > { grade = "A" } else-if < score => 80 > { grade = "B" } else { grade = "C" }')
      expect(result).to eq("B")
      expect(evaluate("grade")).to eq("B")
    end

    it "uses hyouji in if statements" do
      expect {
        evaluate('if < 5 > 3 > { hyouji("Five is greater") } else { hyouji("Five is not greater") }')
      }.to output("Five is greater\n").to_stdout
    end

    it "combines string operations in if body" do
      evaluate('name = "Bob"')
      evaluate("age = 25")
      result = evaluate('if < age => 18 > { message = "Hello " + name + ", you are " + age + " years old" }')
      expect(result).to eq("Hello Bob, you are 25 years old")
    end
  end

  # while文のテスト（文字列込み）
  describe "while statements with strings" do
    it "uses hyouji in while loops" do
      evaluate("counter = 0")
      expected_output = "Count: 0\nCount: 1\nCount: 2\n"

      expect {
        evaluate('while < counter < 3 > { hyouji("Count: " + counter) counter = counter + 1 }')
      }.to output(expected_output).to_stdout
    end

    it "builds strings in while loops" do
      evaluate("i = 1")
      evaluate('result = ""')
      evaluate('while < i =< 3 > { result = result + i i = i + 1 }')
      expect(evaluate("result")).to eq("123")
    end

    it "processes string data in loops" do
      evaluate("count = 0")
      evaluate('status = "starting"')
      result = evaluate('while < count < 2 > { status = "processing " + count count = count + 1 }')
      expect(result).to eq(2)
      expect(evaluate("status")).to eq("processing 1")
    end
  end

  # STEP8新機能: 統合テストケース
  describe "step8 integration scenarios" do
    it "greeting system with user input simulation" do
      evaluate('name = "Alice"')
      evaluate("age = 25")
      evaluate('greeting = "Hello " + name + "!"')
      evaluate('info = name + " is " + age + " years old"')

      expect(evaluate("greeting")).to eq("Hello Alice!")
      expect(evaluate("info")).to eq("Alice is 25 years old")

      expect {
        evaluate("hyouji(greeting)")
        evaluate("hyouji(info)")
      }.to output("Hello Alice!\nAlice is 25 years old\n").to_stdout
    end

    it "number guessing game simulation" do
      evaluate("secret = 7")
      evaluate("guess = 5")
      evaluate('message = ""')

      result = evaluate('if < guess == secret > { message = "Correct!" } else-if < guess < secret > { message = "Too low! Secret is " + secret } else { message = "Too high! Secret is " + secret }')
      expect(result).to eq("Too low! Secret is 7")
      expect(evaluate("message")).to eq("Too low! Secret is 7")
    end

    it "countdown with string formatting" do
      evaluate("count = 3")
      expected_output = "Countdown: 3\nCountdown: 2\nCountdown: 1\nLiftoff!\n"

      expect {
        evaluate('while < count > 0 > { hyouji("Countdown: " + count) count = count - 1 }')
        evaluate('hyouji("Liftoff!")')
      }.to output(expected_output).to_stdout
    end

    it "factorial with detailed output" do
      evaluate("n = 4")
      evaluate("factorial = 1")
      evaluate("i = 1")

      expected_output = "Calculating 1! = 1\nCalculating 2! = 2\nCalculating 3! = 6\nCalculating 4! = 24\nFinal result: 24\n"

      expect {
        evaluate('while < i =< n > { factorial = factorial * i hyouji("Calculating " + i + "! = " + factorial) i = i + 1 }')
        evaluate('hyouji("Final result: " + factorial)')
      }.to output(expected_output).to_stdout

      expect(evaluate("factorial")).to eq(24)
    end

    it "grade calculation with string reports" do
      evaluate("score = 85")
      evaluate('student = "John"')
      evaluate('subject = "Math"')

      result = evaluate('if < score => 90 > { grade = "A" level = "Excellent" } else-if < score => 80 > { grade = "B" level = "Good" } else-if < score => 70 > { grade = "C" level = "Average" } else { grade = "F" level = "Poor" }')

      expect(result).to eq("Good")
      expect(evaluate("grade")).to eq("B")
      expect(evaluate("level")).to eq("Good")

      expect {
        evaluate('hyouji(student + " scored " + score + " in " + subject)')
        evaluate('hyouji("Grade: " + grade + " (" + level + ")")')
      }.to output("John scored 85 in Math\nGrade: B (Good)\n").to_stdout
    end

    it "shopping cart simulation" do
      evaluate("item1_price = 100")
      evaluate("item2_price = 250")
      evaluate("item3_price = 75")
      evaluate("total = item1_price + item2_price + item3_price")
      evaluate("tax_rate = 8")
      evaluate("tax = total * tax_rate / 100")
      evaluate("final_total = total + tax")

      expect {
        evaluate('hyouji("Subtotal: " + total)')
        evaluate('hyouji("Tax (" + tax_rate + "%): " + tax)')
        evaluate('hyouji("Total: " + final_total)')
      }.to output("Subtotal: 425\nTax (8%): 34\nTotal: 459\n").to_stdout

      expect(evaluate("final_total")).to eq(459)
    end

    it "string building with conditionals" do
      evaluate("temperature = 25")
      evaluate('weather = ""')
      evaluate('activity = ""')

      evaluate('if < temperature > 30 > { weather = "hot" activity = "swimming" } else-if < temperature > 20 > { weather = "warm" activity = "walking" } else-if < temperature > 10 > { weather = "cool" activity = "reading" } else { weather = "cold" activity = "staying inside" }')

      evaluate('report = "Today is " + weather + " (" + temperature + " degrees). Good for " + activity + "."')

      expect(evaluate("report")).to eq("Today is warm (25 degrees). Good for walking.")

      expect {
        evaluate("hyouji(report)")
      }.to output("Today is warm (25 degrees). Good for walking.\n").to_stdout
    end

    it "complex nested control with strings" do
      evaluate("students = 3")
      evaluate("current_student = 1")
      evaluate('class_report = "Class Report:\\n"')

      expected_output = "Processing student 1\nProcessing student 2\nProcessing student 3\nClass Report:\nProcessed 3 students\n"

      expect {
        evaluate('while < current_student =< students > { hyouji("Processing student " + current_student) current_student = current_student + 1 }')
        evaluate('class_report = class_report + "Processed " + students + " students"')
        evaluate('hyouji(class_report)')
      }.to output(expected_output).to_stdout
    end

    it "error message generation" do
      evaluate("error_code = 404")
      evaluate('message = ""')

      result = evaluate('if < error_code == 200 > { message = "OK" } else-if < error_code == 404 > { message = "Not Found" } else-if < error_code == 500 > { message = "Internal Server Error" } else { message = "Unknown Error" }')

      expect(result).to eq("Not Found")

      evaluate('full_message = "Error " + error_code + ": " + message')
      expect(evaluate("full_message")).to eq("Error 404: Not Found")
    end
  end

  # 比較演算子のテスト（既存の数値版）
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

  # while文のテスト（既存の数値版）
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
  end

  # エラーケース
  describe "error handling" do
    it "raises error when if condition is not boolean" do
      expect { evaluate("if < 42 > { x = 1 }") }.to raise_error(/The condition of an if statement must be a boolean/)
    end

    it "raises error when while condition is not boolean" do
      expect { evaluate("while < 42 > { x = 1 }") }.to raise_error(/The condition of a while statement must be a boolean/)
    end

    it "prevents infinite loops" do
      expect { evaluate("while < true > { x = 1 }") }.to raise_error(/Loop exceeded maximum iterations.*Possible infinite loop detected/)
    end

    it "raises syntax error for malformed hyouji statement" do
      expect { evaluate("hyouji") }.to raise_error(/Expected/)
      expect { evaluate("hyouji(") }.to raise_error(/Unexpected/)
      expect { evaluate('hyouji("hello"') }.to raise_error(/Expected/)
    end

    it "raises error for unterminated strings" do
      expect { evaluate('"hello') }.to raise_error(/Unterminated string/)
      expect { evaluate("'world") }.to raise_error(/Unterminated string/)
    end

    it "raises syntax error for malformed string concatenation" do
      expect { evaluate('"hello" +') }.to raise_error(/Unexpected/)
    end
  end
end
