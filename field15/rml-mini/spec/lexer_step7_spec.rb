# spec/lexer_step7_spec.rb
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

    # 比較演算子のテスト
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

    # if文とwhile文のキーワードテスト
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

      # STEP7新機能: while キーワード
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

        # STEP7: while キーワードと類似の識別子の区別
        expect(token_types("while whilst")).to eq([:while, :identifier, :eol])
        expect(token_values("while whilst")).to eq([nil, "whilst", nil])
      end

      it "tokenizes all control flow keywords together" do
        input = "if else-if else while"
        expect(token_types(input)).to eq([:if, :else_if, :else, :while, :eol])
        expect(token_values(input)).to eq([nil, nil, nil, nil, nil])
      end
    end

    # STEP7新機能: while文のテスト
    describe "while statement tokenization" do
      it "tokenizes basic while statement" do
        input = "while < x > 0 > { x = x - 1 }"
        expected_types = [
          :while, :less, :identifier, :greater, :int, :greater,
          :l_brace, :identifier, :equals, :identifier, :minus, :int, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)

        expected_values = [
          nil, nil, "x", nil, 0, nil,
          nil, "x", nil, "x", nil, 1, nil,
          nil
        ]
        expect(token_values(input)).to eq(expected_values)
      end

      it "tokenizes while with boolean condition" do
        input = "while < flag == true > { counter = counter + 1 }"
        expected_types = [
          :while, :less, :identifier, :equal_equal, :true, :greater,
          :l_brace, :identifier, :equals, :identifier, :plus, :int, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes while with complex condition" do
        input = "while < (x + y) =< 10 > { result = result * 2 }"
        expected_types = [
          :while, :less,
          :l_paren, :identifier, :plus, :identifier, :r_paren,
          :equal_less, :int, :greater,
          :l_brace, :identifier, :equals, :identifier, :asterisk, :int, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes nested control structures" do
        input = "if < x > 0 > { while < y > 0 > { y = y - 1 } }"
        expected_types = [
          :if, :less, :identifier, :greater, :int, :greater,
          :l_brace,
          :while, :less, :identifier, :greater, :int, :greater,
          :l_brace, :identifier, :equals, :identifier, :minus, :int, :r_brace,
          :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end
    end

    # 複合的なテスト
    describe "complex expressions" do
      it "tokenizes arithmetic with comparison" do
        input = "2 + 3 == 5"
        expect(token_types(input)).to eq([:int, :plus, :int, :equal_equal, :int, :eol])
        expect(token_values(input)).to eq([2, nil, 3, nil, 5, nil])
      end

      it "tokenizes variable assignment with comparison" do
        input = "result = x > y"
        expect(token_types(input)).to eq([:identifier, :equals, :identifier, :greater, :identifier, :eol])
        expect(token_values(input)).to eq(["result", nil, "x", nil, "y", nil])
      end

      it "tokenizes boolean assignment" do
        input = "flag = true"
        expect(token_types(input)).to eq([:identifier, :equals, :true, :eol])
        expect(token_values(input)).to eq(["flag", nil, nil, nil])
      end

      it "tokenizes if statement" do
        input = "if < x > 0 > { result = 1 }"
        expected_types = [:if, :less, :identifier, :greater, :int, :greater, :l_brace, :identifier, :equals, :int, :r_brace, :eol]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes if-else-if statement" do
        input = "if < a > { x = 1 } else-if < b > { x = 2 } else { x = 3 }"
        expected_types = [
          :if, :less, :identifier, :greater, :l_brace, :identifier, :equals, :int, :r_brace,
          :else_if, :less, :identifier, :greater, :l_brace, :identifier, :equals, :int, :r_brace,
          :else, :l_brace, :identifier, :equals, :int, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      # STEP7: while文を含む複合的な式
      it "tokenizes factorial calculation with while" do
        input = "factorial = 1 while < i =< n > { factorial = factorial * i }"
        expected_types = [
          :identifier, :equals, :int,
          :while, :less, :identifier, :equal_less, :identifier, :greater,
          :l_brace, :identifier, :equals, :identifier, :asterisk, :identifier, :r_brace,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end

      it "tokenizes custom comparison operators" do
        input = "a =< b => c"
        expect(token_types(input)).to eq([:identifier, :equal_less, :identifier, :equal_greater, :identifier, :eol])
      end

      it "tokenizes parenthesized comparison" do
        input = "(x + y) == (a * b)"
        expected_types = [
          :l_paren, :identifier, :plus, :identifier, :r_paren,
          :equal_equal,
          :l_paren, :identifier, :asterisk, :identifier, :r_paren,
          :eol
        ]
        expect(token_types(input)).to eq(expected_types)
      end
    end

    # 空白とフォーマット
    describe "whitespace handling" do
      it "skips whitespace correctly" do
        expect(token_types("  5   +   3  ")).to eq([:int, :plus, :int, :eol])
        expect(token_types("if < true > { x = 1 }")).to eq([:if, :less, :true, :greater, :l_brace, :identifier, :equals, :int, :r_brace, :eol])
        expect(token_types("while < false > { y = 2 }")).to eq([:while, :less, :false, :greater, :l_brace, :identifier, :equals, :int, :r_brace, :eol])
      end

      it "handles newlines" do
        input = "x = 5\ny = 10"
        # 改行は whitespace として扱われ、スキップされる
        expect(token_types(input)).to eq([:identifier, :equals, :int, :identifier, :equals, :int, :eol])
      end
    end

    # peek_token機能テスト
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

      it "works with complex expressions" do
        lexer = described_class.new("if < true > { x = 1 }")

        expect(lexer.peek_token.type).to eq(:if)
        expect(lexer.next_token.type).to eq(:if)

        expect(lexer.peek_token.type).to eq(:less)
        expect(lexer.next_token.type).to eq(:less)

        expect(lexer.peek_token.type).to eq(:true)
        expect(lexer.next_token.type).to eq(:true)
      end

      # STEP7: while文でのpeek_token テスト
      it "works with while statements" do
        lexer = described_class.new("while < x > 0 >")

        expect(lexer.peek_token.type).to eq(:while)
        expect(lexer.next_token.type).to eq(:while)

        expect(lexer.peek_token.type).to eq(:less)
        expect(lexer.next_token.type).to eq(:less)

        expect(lexer.peek_token.type).to eq(:identifier)
        expect(lexer.next_token.type).to eq(:identifier)
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

      it "handles edge cases" do
        # 空文字列
        expect(token_types("")).to eq([:eol])

        # 空白のみ
        expect(token_types("   ")).to eq([:eol])
      end
    end
  end
end
