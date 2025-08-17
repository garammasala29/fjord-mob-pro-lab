# spec/lexer_step8_spec.rb
require_relative "../lib/lexer"

RSpec.describe Lexer do
  def tokenize(input)
    lexer = described_class.new(input)
    tokens = []
    loop do
      token = lexer.next_token
      tokens << token
      break if token.type == :eol
    end
    tokens
  end

  def token_types(input)
    tokenize(input).map(&:type)
  end

  def token_values(input)
    tokenize(input).map(&:value)
  end

  describe "#next_token" do
    # 既存の機能テスト
    describe "basic tokens (from previous steps)" do
      it "tokenizes integers" do
        expect(token_types("123")).to eq([:int, :eol])
        expect(token_values("123")).to eq([123, nil])
      end

      it "tokenizes arithmetic operators" do
        expect(token_types("+ - * /")).to eq([:plus, :minus, :asterisk, :slash, :eol])
      end

      it "tokenizes parentheses" do
        expect(token_types("( )")).to eq([:l_paren, :r_paren, :eol])
      end

      it "tokenizes assignment" do
        expect(token_types("=")).to eq([:equals, :eol])
      end

      it "tokenizes identifiers" do
        expect(token_types("variable")).to eq([:identifier, :eol])
        expect(token_values("variable")).to eq(["variable", nil])

        expect(token_types("x")).to eq([:identifier, :eol])
        expect(token_values("x")).to eq(["x", nil])
      end
    end

    # Boolean型のテスト
    describe "boolean literals" do
      it "tokenizes true" do
        expect(token_types("true")).to eq([:true, :eol])
        expect(token_values("true")).to eq([nil, nil])
      end

      it "tokenizes false" do
        expect(token_types("false")).to eq([:false, :eol])
        expect(token_values("false")).to eq([nil, nil])
      end

      it "distinguishes boolean from identifiers" do
        expect(token_types("true false truthy falsy")).to eq([:true, :false, :identifier, :identifier, :eol])
        expect(token_values("true false truthy falsy")).to eq([nil, nil, "truthy", "falsy", nil])
      end
    end

    # STEP8新機能: 文字列リテラルのテスト
    describe "string literals" do
      it "tokenizes double-quoted strings" do
        expect(token_types('"Hello"')).to eq([:string, :eol])
        expect(token_values('"Hello"')).to eq(["Hello", nil])
      end

      it "tokenizes single-quoted strings" do
        expect(token_types("'World'")).to eq([:string, :eol])
        expect(token_values("'World'")).to eq(["World", nil])
      end

      it "tokenizes empty strings" do
        expect(token_types('""')).to eq([:string, :eol])
        expect(token_values('""')).to eq(["", nil])

        expect(token_types("''")).to eq([:string, :eol])
        expect(token_values("''")).to eq(["", nil])
      end

      it "tokenizes strings with spaces" do
        expect(token_types('"Hello World"')).to eq([:string, :eol])
        expect(token_values('"Hello World"')).to eq(["Hello World", nil])
      end

      it "tokenizes strings with numbers" do
        expect(token_types('"Count: 123"')).to eq([:string, :eol])
        expect(token_values('"Count: 123"')).to eq(["Count: 123", nil])
      end

      it "handles basic escape sequences" do
        expect(token_values('"Hello\\nWorld"')).to eq(["Hello\nWorld", nil])
        expect(token_values('"Tab\\tSeparated"')).to eq(["Tab\tSeparated", nil])
        expect(token_values('"Quote: \\"Hi\\""')).to eq(['Quote: "Hi"', nil])
        expect(token_values("'Single: \\'Hi\\''")).to eq(["Single: 'Hi'", nil])
        expect(token_values('"Backslash: \\\\"')).to eq(["Backslash: \\", nil])
      end

      it "handles carriage return escape sequence" do
        expect(token_values('"Line\\rReturn"')).to eq(["Line\rReturn", nil])
      end

      it "distinguishes different quote types" do
        input = '"double" \'single\''
        expect(token_types(input)).to eq([:string, :string, :eol])
        expect(token_values(input)).to eq(["double", "single", nil])
      end
    end

    # STEP8新機能: hyoujiキーワードのテスト
    describe "hyouji keyword" do
      it "tokenizes hyouji" do
        expect(token_types("hyouji")).to eq([:hyouji, :eol])
        expect(token_values("hyouji")).to eq([nil, nil])
      end

      it "distinguishes hyouji from similar identifiers" do
        expect(token_types("hyouji hyoujii")).to eq([:hyouji, :identifier, :eol])
        expect(token_values("hyouji hyoujii")).to eq([nil, "hyoujii", nil])

        expect(token_types("display hyouji show")).to eq([:identifier, :hyouji, :identifier, :eol])
        expect(token_values("display hyouji show")).to eq(["display", nil, "show", nil])
      end

      it "tokenizes hyouji statement with parentheses" do
        expect(token_types("hyouji()")).to eq([:hyouji, :l_paren, :r_paren, :eol])
      end

      it "tokenizes hyouji with string argument" do
        input = 'hyouji("Hello")'
        expect(token_types(input)).to eq([:hyouji, :l_paren, :string, :r_paren, :eol])
        expect(token_values(input)).to eq([nil, nil, "Hello", nil, nil])
      end

      it "tokenizes hyouji with variable argument" do
        input = "hyouji(message)"
        expect(token_types(input)).to eq([:hyouji, :l_paren, :identifier, :r_paren, :eol])
        expect(token_values(input)).to eq([nil, nil, "message", nil, nil])
      end
    end

    # 比較演算子のテスト（既存）
    describe "comparison operators" do
      it "tokenizes equality ==" do
        expect(token_types("==")).to eq([:equal_equal, :eol])
      end

      it "tokenizes inequality !=" do
        expect(token_types("!=")).to eq([:not_equal, :eol])
      end

      it "tokenizes less than <" do
        expect(token_types("<")).to eq([:less, :eol])
      end

      it "tokenizes greater than >" do
        expect(token_types(">")).to eq([:greater, :eol])
      end

      it "tokenizes less than or equal =< (custom syntax)" do
        expect(token_types("=<")).to eq([:equal_less, :eol])
      end

      it "tokenizes greater than or equal => (custom syntax)" do
        expect(token_types("=>")).to eq([:equal_greater, :eol])
      end

      it "distinguishes = from == and =< and =>" do
        expect(token_types("= == =< =>")).to eq([:equals, :equal_equal, :equal_less, :equal_greater, :eol])
      end

      it "tokenizes comparison in expressions" do
        expect(token_types("5 == 3")).to eq([:int, :equal_equal, :int, :eol])
        expect(token_types("x != y")).to eq([:identifier, :not_equal, :identifier, :eol])
        expect(token_types("a =< b")).to eq([:identifier, :equal_less, :identifier, :eol])
      end
    end

    # if文とwhile文のキーワードテスト（既存）
    describe "control flow keywords" do
      it "tokenizes if" do
        expect(token_types("if")).to eq([:if, :eol])
      end

      it "tokenizes else" do
        expect(token_types("else")).to eq([:else, :eol])
      end

      it "tokenizes else-if" do
        expect(token_types("else-if")).to eq([:else_if, :eol])
      end

      it "tokenizes while" do
        expect(token_types("while")).to eq([:while, :eol])
        expect(token_values("while")).to eq([nil, nil])
      end

      it "tokenizes braces" do
        expect(token_types("{ }")).to eq([:l_brace, :r_brace, :eol])
      end

      it "distinguishes keywords from similar identifiers" do
        expect(token_types("if ifdef")).to eq([:if, :identifier, :eol])
        expect(token_values("if ifdef")).to eq([nil, "ifdef", nil])

        expect(token_types("else elsewhere")).to eq([:else, :identifier, :eol])
        expect(token_values("else elsewhere")).to eq([nil, "elsewhere", nil])

        expect(token_types("while whilst")).to eq([:while, :identifier, :eol])
        expect(token_values("while whilst")).to eq([nil, "whilst", nil])
      end

      it "tokenizes all control flow keywords together" do
        input = "if else-if else while hyouji"
        expect(token_types(input)).to eq([:if, :else_if, :else, :while, :hyouji, :eol])
        expect(token_values(input)).to eq([nil, nil, nil, nil, nil, nil])
      end
    end

    # STEP8新機能: 文字列を含む複合的なテスト
    describe "step8 complex expressions" do
      it "tokenizes string concatenation" do
        input = '"Hello " + "World"'
        expect(token_types(input)).to eq([:string, :plus, :string, :eol])
        expect(token_values(input)).to eq(["Hello ", nil, "World", nil])
      end

      it "tokenizes string and variable concatenation" do
        input = '"Hello " + name'
        expect(token_types(input)).to eq([:string, :plus, :identifier, :eol])
        expect(token_values(input)).to eq(["Hello ", nil, "name", nil])
      end

      it "tokenizes string and number concatenation" do
        input = '"Count: " + 42'
        expect(token_types(input)).to eq([:string, :plus, :int, :eol])
        expect(token_values(input)).to eq(["Count: ", nil, 42, nil])
      end

      it "tokenizes string assignment" do
        input = 'message = "Hello World"'
        expect(token_types(input)).to eq([:identifier, :equals, :string, :eol])
        expect(token_values(input)).to eq(["message", nil, "Hello World", nil])
      end

      it "tokenizes hyouji with string concatenation" do
        input = 'hyouji("Hello " + name)'
        expect(token_types(input)).to eq([:hyouji, :l_paren, :string, :plus, :identifier, :r_paren, :eol])
        expect(token_values(input)).to eq([nil, nil, "Hello ", nil, "name", nil, nil])
      end

      it "tokenizes hyouji in if statement" do
        input = 'if < x > 0 > { hyouji("Positive") }'
        expected_types = [
          :if, :less, :identifier, :greater, :int, :greater,
          :l_brace, :hyouji, :l_paren, :string, :r_paren, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes hyouji in while loop" do
        input = 'while < counter < 3 > { hyouji("Count: " + counter) }'
        expected_types = [
          :while, :less, :identifier, :less, :int, :greater,
          :l_brace, :hyouji, :l_paren, :string, :plus, :identifier, :r_paren, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes mixed string and boolean operations" do
        input = 'result = "Value: " + (x > 5)'
        expected_types = [
          :identifier, :equals, :string, :plus,
          :l_paren, :identifier, :greater, :int, :r_paren,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end
    end

    describe "function keywords" do
      it "tokenizes func keyword" do
        expect(token_types("func")).to eq([:func, :eol])
        expect(token_values("func")).to eq([nil, nil])
      end

      it "tokenizes return keyword" do
        expect(token_types("return")).to eq([:return, :eol])
        expect(token_values("return")).to eq([nil, nil])
      end

      it "distinguishes func and return from similar identifiers" do
        expect(token_types("func function")).to eq([:func, :identifier, :eol])
        expect(token_values("func function")).to eq([nil, "function", nil])

        expect(token_types("return returns")).to eq([:return, :identifier, :eol])
        expect(token_values("return returns")).to eq([nil, "returns", nil])

        expect(token_types("myfunc func return myreturn")).to eq([:identifier, :func, :return, :identifier, :eol])
        expect(token_values("myfunc func return myreturn")).to eq(["myfunc", nil, nil, "myreturn", nil])
      end
    end

    # STEP9新機能: カンマトークンのテスト
    describe "comma token" do
      it "tokenizes comma" do
        expect(token_types(",")).to eq([:comma, :eol])
        expect(token_values(",")).to eq([nil, nil])
      end

      it "tokenizes comma in parameter lists" do
        expect(token_types("a, b, c")).to eq([:identifier, :comma, :identifier, :comma, :identifier, :eol])
        expect(token_values("a, b, c")).to eq(["a", nil, "b", nil, "c", nil])
      end

      it "tokenizes comma with spaces" do
        expect(token_types("x , y")).to eq([:identifier, :comma, :identifier, :eol])
        expect(token_values("x , y")).to eq(["x", nil, "y", nil])
      end
    end

    # STEP9新機能: 関数名での ? と ! のサポート
    describe "function names with ? and !" do
      it "tokenizes identifier with question mark" do
        expect(token_types("even?")).to eq([:identifier, :eol])
        expect(token_values("even?")).to eq(["even?", nil])

        expect(token_types("is_valid?")).to eq([:identifier, :eol])
        expect(token_values("is_valid?")).to eq(["is_valid?", nil])
      end

      it "tokenizes identifier with exclamation mark" do
        expect(token_types("reset!")).to eq([:identifier, :eol])
        expect(token_values("reset!")).to eq(["reset!", nil])

        expect(token_types("sort!")).to eq([:identifier, :eol])
        expect(token_values("sort!")).to eq(["sort!", nil])
      end

      it "tokenizes identifier with both ? and !" do
        expect(token_types("test?!")).to eq([:identifier, :eol])
        expect(token_values("test?!")).to eq(["test?!", nil])

        expect(token_types("check!?")).to eq([:identifier, :eol])
        expect(token_values("check!?")).to eq(["check!?", nil])
      end

      it "tokenizes complex identifiers with underscores and symbols" do
        expect(token_types("is_even? reset_all! get_user_name")).to eq([:identifier, :identifier, :identifier, :eol])
        expect(token_values("is_even? reset_all! get_user_name")).to eq(["is_even?", "reset_all!", "get_user_name", nil])
      end

      it "distinguishes ? and ! within identifiers from standalone operators" do
        # NOTE: 現在の実装では ? と ! は単独の演算子としては定義されていない
        # 将来的に追加される可能性を考慮したテスト
        expect(token_types("func? + reset!")).to eq([:identifier, :plus, :identifier, :eol])
        expect(token_values("func? + reset!")).to eq(["func?", nil, "reset!", nil])
      end
    end

    # STEP9新機能: 関数定義の構文テスト
    describe "function definition syntax" do
      it "tokenizes simple function definition" do
        input = "func test() { return 42 }"
        expected_types = [
          :func, :identifier, :l_paren, :r_paren,
          :l_brace, :return, :int, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)

        tokens = tokenize(input)
        expect(tokens[1].value).to eq("test")  # 関数名
        expect(tokens[6].value).to eq(42)      # 戻り値
      end

      it "tokenizes function with parameters" do
        input = "func add(a, b) { return a + b }"
        expected_types = [
          :func, :identifier, :l_paren, :identifier, :comma, :identifier, :r_paren,
          :l_brace, :return, :identifier, :plus, :identifier, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)

        tokens = tokenize(input)
        expect(tokens[1].value).to eq("add")   # 関数名
        expect(tokens[3].value).to eq("a")     # 第1パラメータ
        expect(tokens[5].value).to eq("b")     # 第2パラメータ
      end

      it "tokenizes function with ? and ! names" do
        input = "func even?(n) { return n / 2 * 2 == n }"
        expected_types = [
          :func, :identifier, :l_paren, :identifier, :r_paren,
          :l_brace, :return, :identifier, :slash, :int, :asterisk, :int, :equal_equal, :identifier, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
        expect(tokenize(input)[1].value).to eq("even?")
      end

      it "tokenizes function call" do
        input = "result = add(3, 4)"
        expected_types = [
          :identifier, :equals, :identifier, :l_paren, :int, :comma, :int, :r_paren,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)

        tokens = tokenize(input)
        expect(tokens[2].value).to eq("add")   # 関数名
        expect(tokens[4].value).to eq(3)       # 第1引数
        expect(tokens[6].value).to eq(4)       # 第2引数
      end

      it "tokenizes recursive function call" do
        input = "return n * factorial(n - 1)"
        expected_types = [
          :return, :identifier, :asterisk, :identifier, :l_paren, :identifier, :minus, :int, :r_paren,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
        expect(tokenize(input)[3].value).to eq("factorial")
      end
    end

    # STEP9新機能: return文のテスト
    describe "return statements" do
      it "tokenizes return with value" do
        input = "return 42"
        expect(token_types(input)).to eq([:return, :int, :eol])
        expect(token_values(input)).to eq([nil, 42, nil])
      end

      it "tokenizes return with expression" do
        input = "return a + b"
        expect(token_types(input)).to eq([:return, :identifier, :plus, :identifier, :eol])
        expect(token_values(input)).to eq([nil, "a", nil, "b", nil])
      end

      it "tokenizes return without value" do
        input = "return"
        expect(token_types(input)).to eq([:return, :eol])
        expect(token_values(input)).to eq([nil, nil])
      end

      it "tokenizes return with function call" do
        input = "return factorial(n - 1)"
        expected_types = [:return, :identifier, :l_paren, :identifier, :minus, :int, :r_paren, :eol]
        expect(token_types(input)).to eq(expected_types)
      end
    end

    # STEP9新機能: 複合的な関数構文テスト
    describe "complex function expressions" do
      it "tokenizes function definition with string concatenation" do
        input = 'func greet(name) { return "Hello, " + name }'
        expected_types = [
          :func, :identifier, :l_paren, :identifier, :r_paren,
          :l_brace, :return, :string, :plus, :identifier, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes function with conditional return" do
        input = "func max(a, b) { if < a > b > { return a } else { return b } }"
        expected_types = [
          :func, :identifier, :l_paren, :identifier, :comma, :identifier, :r_paren,
          :l_brace,
          :if, :less, :identifier, :greater, :identifier, :greater,
          :l_brace, :return, :identifier, :r_brace,
          :else,
          :l_brace, :return, :identifier, :r_brace,
          :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes function call within function call" do
        input = "result = add(multiply(2, 3), 4)"
        expected_types = [
          :identifier, :equals, :identifier, :l_paren,
          :identifier, :l_paren, :int, :comma, :int, :r_paren,
          :comma, :int, :r_paren,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes function with hyouji statement" do
        input = 'func debug(msg) { hyouji("Debug: " + msg) }'
        expected_types = [
          :func, :identifier, :l_paren, :identifier, :r_paren,
          :l_brace, :hyouji, :l_paren, :string, :plus, :identifier, :r_paren, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes function with while loop" do
        input = "func countdown(n) { while < n > 0 > { hyouji(n) n = n - 1 } }"
        expected_types = [
          :func, :identifier, :l_paren, :identifier, :r_paren,
          :l_brace,
          :while, :less, :identifier, :greater, :int, :greater,
          :l_brace, :hyouji, :l_paren, :identifier, :r_paren, :identifier, :equals, :identifier, :minus, :int, :r_brace,
          :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end
    end

    # STEP9新機能: 関数名の特殊文字に関する注意点
    describe "function name edge cases" do
      it "handles identifiers that start with keywords" do
        # func で始まるが func ではない識別子
        expect(token_types("function")).to eq([:identifier, :eol])
        expect(token_values("function")).to eq(["function", nil])

        expect(token_types("functor")).to eq([:identifier, :eol])
        expect(token_values("functor")).to eq(["functor", nil])

        # return で始まるが return ではない識別子
        expect(token_types("returner")).to eq([:identifier, :eol])
        expect(token_values("returner")).to eq(["returner", nil])
      end

      it "handles mixed alphanumeric with symbols" do
        expect(token_types("test123?")).to eq([:identifier, :eol])
        expect(token_values("test123?")).to eq(["test123?", nil])

        expect(token_types("func2!")).to eq([:identifier, :eol])
        expect(token_values("func2!")).to eq(["func2!", nil])
      end
    end

    # 空白とフォーマット（既存）
    describe "whitespace handling" do
      it "skips whitespace correctly" do
        expect(token_types("  5   +   3  ")).to eq([:int, :plus, :int, :eol])
        expect(token_types("if < true > { x = 1 }")).to eq([:if, :less, :true, :greater, :l_brace, :identifier, :equals, :int, :r_brace, :eol])
        expect(token_types("while < false > { y = 2 }")).to eq([:while, :less, :false, :greater, :l_brace, :identifier, :equals, :int, :r_brace, :eol])
      end

      it "handles strings with whitespace correctly" do
        expect(token_types('  "Hello World"  ')).to eq([:string, :eol])
        expect(token_values('  "Hello World"  ')).to eq(["Hello World", nil])
      end

      it "handles newlines" do
        input = "x = 5\ny = 10"
        # 改行は whitespace として扱われ、スキップされる
        expect(token_types(input)).to eq([:identifier, :equals, :int, :identifier, :equals, :int, :eol])
      end
    end

    # peek_token機能テスト（既存）
    describe "#peek_token" do
      it "returns next token without advancing" do
        lexer = described_class.new("5 + 3")

        # 最初のトークンを peek
        peeked = lexer.peek_token
        expect(peeked.type).to eq(:int)
        expect(peeked.value).to eq(5)

        # 実際に next_token を呼んでも同じトークン
        actual = lexer.next_token
        expect(actual.type).to eq(:int)
        expect(actual.value).to eq(5)

        # 次のトークンを peek
        peeked = lexer.peek_token
        expect(peeked.type).to eq(:plus)

        # 実際に next_token を呼んでも同じトークン
        actual = lexer.next_token
        expect(actual.type).to eq(:plus)
      end

      it "works with strings" do
        lexer = described_class.new('"Hello" + "World"')

        expect(lexer.peek_token.type).to eq(:string)
        expect(lexer.next_token.value).to eq("Hello")

        expect(lexer.peek_token.type).to eq(:plus)
        expect(lexer.next_token.type).to eq(:plus)

        expect(lexer.peek_token.type).to eq(:string)
        expect(lexer.next_token.value).to eq("World")
      end

      it "works with hyouji statements" do
        lexer = described_class.new('hyouji("test")')

        expect(lexer.peek_token.type).to eq(:hyouji)
        expect(lexer.next_token.type).to eq(:hyouji)

        expect(lexer.peek_token.type).to eq(:l_paren)
        expect(lexer.next_token.type).to eq(:l_paren)

        expect(lexer.peek_token.type).to eq(:string)
        expect(lexer.next_token.value).to eq("test")
      end
    end

    # エラーケース
    describe "error handling" do
      it "raises error for unknown characters" do
        expect { tokenize("@") }.to raise_error(/Unknown character/)
        expect { tokenize("$") }.to raise_error(/Unknown character/)
        expect { tokenize("#") }.to raise_error(/Unknown character/)
      end

      it "raises error for incomplete operators" do
        # ! だけでは不正（!= でないと）
        expect { tokenize("!") }.to raise_error(/Unknown character/)
      end

      it "raises error for unterminated strings" do
        expect { tokenize('"Hello') }.to raise_error(/Unterminated string/)
        expect { tokenize("'World") }.to raise_error(/Unterminated string/)
      end

      it "raises error for unknown escape sequences" do
        expect { tokenize('"Hello\\k"') }.to raise_error(/Unknown escape sequence/)
        expect { tokenize('"Test\\z"') }.to raise_error(/Unknown escape sequence/)
      end

      it "raises error for escape at end of input" do
        expect { tokenize('"Hello\\') }.to raise_error(/Unterminated string.*escape character/)
      end

      it "handles edge cases" do
        # 空文字列
        expect(token_types("")).to eq([:eol])

        # 空白のみ
        expect(token_types("   ")).to eq([:eol])
      end
    end
  end
end
