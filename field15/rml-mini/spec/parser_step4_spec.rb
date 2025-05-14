# spec/parser_step4_spec.rb
require_relative "../lib/parser_step4"
require_relative "../lib/node"

RSpec.describe ParserStep4 do
  subject { described_class }

  describe ".parse" do
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
