# spec/integration_step8_spec.rb
require_relative "../lib/parser_step9"
require_relative "../lib/evaluator"

RSpec.describe "Integration Step9" do
  let(:parser) { ParserStep9 }
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

  # STEP9新機能: 関数定義と呼び出し
  describe "function definition and calls" do
    describe "basic function definition" do
      it "defines and calls a simple function" do
        result = evaluate('func greet() { "Hello World" }')
        expect(result).to eq("greet")

        expect(evaluate("greet()")).to eq("Hello World")
      end

      it "defines function with parameters" do
        evaluate('func add(a, b) { a + b }')
        expect(evaluate("add(3, 5)")).to eq(8)
        expect(evaluate("add(10, 2)")).to eq(12)
      end

      it "defines function with single parameter" do
        evaluate('func double(x) { x * 2 }')
        expect(evaluate("double(5)")).to eq(10)
        expect(evaluate("double(3)")).to eq(6)
      end

      it "defines function with no parameters" do
        evaluate('func get_constant() { 42 }')
        expect(evaluate("get_constant()")).to eq(42)
      end
    end

    describe "function calls with expressions" do
      it "calls function with expression arguments" do
        evaluate('func multiply(a, b) { a * b }')
        expect(evaluate("multiply(2 + 3, 4)")).to eq(20)
        expect(evaluate("multiply(6, 3 * 2)")).to eq(36)
      end

      it "calls function with variable arguments" do
        evaluate('func subtract(a, b) { a - b }')
        evaluate("x = 10")
        evaluate("y = 3")
        expect(evaluate("subtract(x, y)")).to eq(7)
      end

      it "calls function with string arguments" do
        evaluate('func concat(a, b) { a + b }')
        expect(evaluate('concat("Hello ", "World")')).to eq("Hello World")
      end

      it "uses function result in expressions" do
        evaluate('func square(x) { x * x }')
        expect(evaluate("square(3) + square(4)")).to eq(25)
        expect(evaluate("square(2) * 3")).to eq(12)
      end
    end

    describe "return statements" do
      it "returns explicit values" do
        evaluate('func get_ten() { return 10 }')
        expect(evaluate("get_ten()")).to eq(10)
      end

      it "returns expressions" do
        evaluate('func calculate(x) { return x * 2 + 1 }')
        expect(evaluate("calculate(5)")).to eq(11)
      end

      it "returns early from function" do
        evaluate('func check_positive(x) { if < x > 0 > { return "positive" } return "zero or small" }')
        expect(evaluate("check_positive(5)")).to eq("positive")
        expect(evaluate("check_positive(0)")).to eq("zero or small")
      end

      it "returns without expression (nil)" do
        evaluate('func void_func() { return }')
        expect(evaluate("void_func()")).to be_nil
      end

      it "implicit return of last expression" do
        evaluate('func implicit_return(x) { x + 1 }')
        expect(evaluate("implicit_return(5)")).to eq(6)
      end
    end

    describe "variable scoping" do
      it "function parameters are local" do
        evaluate("x = 100")
        evaluate('func test(x) { x + 1 }')
        expect(evaluate("test(5)")).to eq(6)
        expect(evaluate("x")).to eq(100) # グローバル変数は変更されない
      end

      it "function can access global variables" do
        evaluate("global_var = 42")
        evaluate('func access_global() { global_var + 1 }')
        expect(evaluate("access_global()")).to eq(43)
      end

      it "function can modify global variables" do
        evaluate("y = 200")
        evaluate('func modify_global() { y = 50 y + 1 }')
        expect(evaluate("modify_global()")).to eq(51)
        expect(evaluate("y")).to eq(50) # グローバル変数が変更される
      end

      it "function with truly local variables" do
        evaluate("z = 300")
        evaluate('func local_scope() { local_var = 100 local_var + 1 }')
        expect(evaluate("local_scope()")).to eq(101)
        expect(evaluate("z")).to eq(300) # 異なる名前なので影響なし
        expect { evaluate("local_var") }.to raise_error(/未定義の変数/) # ローカル変数はアクセスできない
      end

      it "nested function calls work correctly" do
        evaluate("outer = 1")
        evaluate('func outer_func(param) { outer_local = param + outer inner_func() }')
        evaluate('func inner_func() { outer + outer_local }')

        # inner_funcがouter_funcから呼ばれたときにouter_localにアクセスできる
        result = evaluate("outer_func(10)")
        expect(result).to eq(12) # outer(1) + outer_local(11) = 12
      end
    end

    describe "string functions" do
      it "functions working with strings" do
        evaluate('func make_greeting(name) { "Hello " + name + "!" }')
        expect(evaluate('make_greeting("Alice")')).to eq("Hello Alice!")
      end

      it "string length simulation function" do
        evaluate('func describe_string(str) { "The string is: " + str }')
        expect(evaluate('describe_string("test")')).to eq("The string is: test")
      end

      it "conditional string functions" do
        evaluate('func get_grade(score) { if < score => 90 > { "A" } else-if < score => 80 > { "B" } else { "C" } }')
        expect(evaluate("get_grade(95)")).to eq("A")
        expect(evaluate("get_grade(85)")).to eq("B")
        expect(evaluate("get_grade(75)")).to eq("C")
      end
    end

    describe "functions with control flow" do
      it "function with if statement" do
        evaluate('func abs(x) { if < x < 10 > { x + 10 } else { x } }')
        expect(evaluate("abs(5)")).to eq(15)
        expect(evaluate("abs(15)")).to eq(15)
        expect(evaluate("abs(0)")).to eq(10)
      end

      it "function with while loop" do
        evaluate('func factorial(n) { result = 1 i = 1 while < i =< n > { result = result * i i = i + 1 } result }')
        expect(evaluate("factorial(5)")).to eq(120)
        expect(evaluate("factorial(3)")).to eq(6)
        expect(evaluate("factorial(1)")).to eq(1)
      end

      it "function with hyouji output" do
        expect {
          evaluate('func debug(value) { hyouji("Debug: " + value) value }')
          result = evaluate("debug(42)")
          expect(result).to eq(42)
        }.to output("Debug: 42\n").to_stdout
      end
    end

    describe "recursive functions" do
      it "simple recursive function" do
        evaluate('func countdown(n) { if < n =< 0 > { return 0 } hyouji("Count: " + n) countdown(n - 1) }')

        expect {
          result = evaluate("countdown(3)")
          expect(result).to eq(0)
        }.to output("Count: 3\nCount: 2\nCount: 1\n").to_stdout
      end

      it "recursive factorial" do
        evaluate('func rec_factorial(n) { if < n =< 1 > { return 1 } return n * rec_factorial(n - 1) }')
        expect(evaluate("rec_factorial(5)")).to eq(120)
        expect(evaluate("rec_factorial(4)")).to eq(24)
        expect(evaluate("rec_factorial(1)")).to eq(1)
      end

      it "recursive fibonacci" do
        evaluate('func fibonacci(n) { if < n =< 1 > { return n } return fibonacci(n - 1) + fibonacci(n - 2) }')
        expect(evaluate("fibonacci(0)")).to eq(0)
        expect(evaluate("fibonacci(1)")).to eq(1)
        expect(evaluate("fibonacci(6)")).to eq(8) # 0,1,1,2,3,5,8
      end

      it "mutual recursion simulation" do
        evaluate('func even(n) { if < n == 0 > { return true } return odd(n - 1) }')
        evaluate('func odd(n) { if < n == 0 > { return false } return even(n - 1) }')
        expect(evaluate("even(4)")).to eq(true)
        expect(evaluate("odd(4)")).to eq(false)
        expect(evaluate("even(5)")).to eq(false)
        expect(evaluate("odd(5)")).to eq(true)
      end
    end

    describe "complex function scenarios" do
      it "calculator functions" do
        evaluate('func calc_add(a, b) { a + b }')
        evaluate('func calc_multiply(a, b) { a * b }')
        evaluate('func calc_power(base, exp) { result = 1 i = 0 while < i < exp > { result = calc_multiply(result, base) i = calc_add(i, 1) } result }')

        expect(evaluate("calc_power(2, 3)")).to eq(8)
        expect(evaluate("calc_power(3, 2)")).to eq(9)
      end

      it "string processing functions" do
        evaluate('func process_data(name, age, city) { "Name: " + name + ", Age: " + age + ", City: " + city }')
        result = evaluate('process_data("Alice", 25, "Tokyo")')
        expect(result).to eq("Name: Alice, Age: 25, City: Tokyo")
      end

      it "validation functions" do
        evaluate('func validate_age(age) { if < age == 0 > { return "Invalid: zero age" } if < age > 150 > { return "Invalid: too old" } return "Valid age" }')
        expect(evaluate("validate_age(25)")).to eq("Valid age")
        expect(evaluate("validate_age(0)")).to eq("Invalid: zero age")
        expect(evaluate("validate_age(200)")).to eq("Invalid: too old")
      end

      it "functions calling other functions" do
        evaluate('func double(x) { x * 2 }')
        evaluate('func quadruple(x) { double(double(x)) }')
        expect(evaluate("quadruple(3)")).to eq(12)
      end

      it "function with complex logic" do
        evaluate('func grade_calculator(score1, score2, score3) { avg = (score1 + score2 + score3) / 3 if < avg => 90 > { return "A (Average: " + avg + ")" } if < avg => 80 > { return "B (Average: " + avg + ")" } return "C (Average: " + avg + ")" }')

        result = evaluate("grade_calculator(85, 90, 95)")
        expect(result).to eq("A (Average: 90)")

        result = evaluate("grade_calculator(80, 85, 85)")
        expect(result).to eq("B (Average: 83)")
      end

      it "game logic simulation" do
        evaluate('func check_win(score, target) { if < score => target > { return "You win! Score: " + score } return "Keep trying! Score: " + score + " (Need: " + target + ")" }')
        expect(evaluate("check_win(100, 80)")).to eq("You win! Score: 100")
        expect(evaluate("check_win(70, 80)")).to eq("Keep trying! Score: 70 (Need: 80)")
      end

      it "data processing pipeline" do
        evaluate('func clean_data(value) { if < value < 5 > { return 5 } return value }')
        evaluate('func scale_data(value) { clean_data(value) * 10 }')
        evaluate('func format_result(value) { "Result: " + scale_data(value) }')

        expect(evaluate("format_result(10)")).to eq("Result: 100")
        expect(evaluate("format_result(3)")).to eq("Result: 50")
      end
    end

    describe "integration with existing features" do
      it "functions in variable assignments" do
        evaluate('func get_value() { 42 }')
        evaluate("result = get_value()")
        expect(evaluate("result")).to eq(42)
      end

      it "functions in if conditions" do
        evaluate('func is_positive(x) { x > 0 }')
        result = evaluate('if < is_positive(5) > { "positive" } else { "not positive" }')
        expect(result).to eq("positive")
      end

      it "functions in while conditions" do
        evaluate("counter = 5")
        evaluate('func should_continue(x) { x > 0 }')
        evaluate('while < should_continue(counter) > { counter = counter - 1 }')
        expect(evaluate("counter")).to eq(0)
      end

      it "functions with hyouji statements" do
        expect {
          evaluate('func announce(message) { hyouji("Announcement: " + message) }')
          evaluate('announce("Hello World")')
        }.to output("Announcement: Hello World\n").to_stdout
      end

      it "complex expression with functions" do
        evaluate('func add(a, b) { a + b }')
        evaluate('func multiply(a, b) { a * b }')
        result = evaluate("add(multiply(3, 4), multiply(2, 5))")
        expect(result).to eq(22) # (3*4) + (2*5) = 12 + 10 = 22
      end
    end
  end

  # エラーハンドリング
  describe "error handling" do
    describe "function definition errors" do
      it "raises error for malformed function definition" do
        expect { evaluate("func") }.to raise_error(/Expected/)
        expect { evaluate("func test") }.to raise_error(/Expected/)
        expect { evaluate("func test(") }.to raise_error(/Expected/)
      end
    end

    describe "function call errors" do
      it "raises error for undefined function" do
        expect { evaluate("undefined_func()") }.to raise_error(/未定義の関数/)
      end

      it "raises error for wrong number of arguments" do
        evaluate('func test(a, b) { a + b }')
        expect { evaluate("test(1)") }.to raise_error(/Wrong number of arguments/)
        expect { evaluate("test(1, 2, 3)") }.to raise_error(/Wrong number of arguments/)
      end

      it "raises error for malformed function call" do
        evaluate('func test() { 42 }')
        expect { evaluate("test(") }.to raise_error(/Unexpected token/)
      end
    end

    describe "recursion limits" do
      it "prevents stack overflow with recursion limit" do
        evaluate('func infinite_recursion(x) { infinite_recursion(x + 1) }')
        expect { evaluate("infinite_recursion(1)") }.to raise_error(/Maximum recursion depth exceeded/)
      end
    end

    describe "return statement errors" do
      it "handles return in global scope gracefully" do
        # グローバルスコープでのreturnはReturnExceptionを発生させる
        expect { evaluate("return 42") }.to raise_error(Evaluator::ReturnException)
      end
    end

    describe "scope errors" do
      it "raises error for accessing function parameters outside function" do
        evaluate('func test(param) { param + 1 }')
        evaluate("test(5)")
        expect { evaluate("param") }.to raise_error(/未定義の変数/)
      end

      it "raises error for accessing function local variables outside function" do
        evaluate('func test() { local_var = 42 local_var }')
        evaluate("test()")
        expect { evaluate("local_var") }.to raise_error(/未定義の変数/)
      end
    end
  end

  # パフォーマンスと制限のテスト
  describe "performance and limits" do
    it "handles reasonable recursion depth" do
      evaluate('func sum_to(n) { if < n =< 0 > { return 0 } return n + sum_to(n - 1) }')
      expect(evaluate("sum_to(10)")).to eq(55) # 1+2+...+10 = 55
    end

    it "handles functions with many parameters" do
      evaluate('func many_params(a, b, c, d, e) { a + b + c + d + e }')
      expect(evaluate("many_params(1, 2, 3, 4, 5)")).to eq(15)
    end

    it "handles nested function calls" do
      evaluate('func f1(x) { x + 1 }')
      evaluate('func f2(x) { f1(x) + 1 }')
      evaluate('func f3(x) { f2(x) + 1 }')
      expect(evaluate("f3(5)")).to eq(8) # 5+1+1+1 = 8
    end
  end

  # 実用的なシナリオ
  describe "practical scenarios" do
    it "mathematical utilities" do
      evaluate('func max(a, b) { if < a > b > { a } else { b } }')
      evaluate('func min(a, b) { if < a < b > { a } else { b } }')
      evaluate('func clamp(value, min_val, max_val) { min(max(value, min_val), max_val) }')

      expect(evaluate("max(5, 3)")).to eq(5)
      expect(evaluate("min(5, 3)")).to eq(3)
      expect(evaluate("clamp(10, 3, 7)")).to eq(7)
      expect(evaluate("clamp(1, 3, 7)")).to eq(3)
      expect(evaluate("clamp(5, 3, 7)")).to eq(5)
    end

    it "string utilities" do
      evaluate('func make_title(text) { "=== " + text + " ===" }')
      evaluate('func make_error(code, message) { "ERROR " + code + ": " + message }')

      expect(evaluate('make_title("Welcome")')).to eq("=== Welcome ===")
      expect(evaluate('make_error(404, "Not Found")')).to eq("ERROR 404: Not Found")
    end

    it "business logic simulation" do
      evaluate('func calculate_tax(amount, rate) { amount * rate / 100 }')
      evaluate('func calculate_total(subtotal, tax_rate) { tax = calculate_tax(subtotal, tax_rate) subtotal + tax }')
      evaluate('func format_price(amount) { "¥" + amount }')

      subtotal = 1000
      tax_rate = 10
      total = evaluate("calculate_total(#{subtotal}, #{tax_rate})")
      expect(total).to eq(1100)

      formatted = evaluate("format_price(#{total})")
      expect(formatted).to eq("¥1100")
    end

    it "game development patterns" do
      evaluate('func create_player(name, level) { "Player: " + name + " (Level " + level + ")" }')
      evaluate('func calculate_damage(base_damage, level) { base_damage + level * 2 }')
      evaluate('func level_up_message(name, new_level) { name + " reached level " + new_level + "!" }')

      expect(evaluate('create_player("Hero", 5)')).to eq("Player: Hero (Level 5)")
      expect(evaluate("calculate_damage(10, 5)")).to eq(20)
      expect(evaluate('level_up_message("Hero", 6)')).to eq("Hero reached level 6!")
    end

    it "report generation" do
      expect {
        evaluate('func print_header(title) { hyouji("=" * 20) hyouji(title) hyouji("=" * 20) }')
        evaluate('func print_item(name, value) { hyouji(name + ": " + value) }')
        evaluate('func print_footer() { hyouji("=" * 20) }')

        # Note: この例では"=" * 20は実装されていないので、単純化
        evaluate('func simple_print_header(title) { hyouji("====================") hyouji(title) hyouji("====================") }')
        evaluate('simple_print_header("Monthly Report")')
        evaluate('print_item("Sales", 150000)')
        evaluate('print_item("Profit", 45000)')
        evaluate('print_footer()')
      }.to output("====================\nMonthly Report\n====================\nSales: 150000\nProfit: 45000\n====================\n").to_stdout
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
