require_relative '../lib/parser_step5'
require_relative '../lib/node'

RSpec.describe ParserStep5 do
  subject { described_class }

  describe ".parse" do
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

    # ----------- 以下ParserStep4のテストを移植 -------------

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

    context "when handling errors" do
      it "raises error on unbalanced parentheses" do
        expect { subject.parse("(2 + 3") }.to raise_error(RuntimeError)
        expect { subject.parse("2 + 3)") }.to raise_error(RuntimeError)
      end
    end
  end
end
