# spec/evaluator_spec.rb
require_relative "../lib/evaluator"
require_relative "../lib/node"

RSpec.describe Evaluator do
  subject { described_class.new }

  describe "#evaluate" do
    it "evaluates integer node" do
      node = Node::Integer.new(42)
      expect(subject.evaluate(node)).to eq(42)
    end

    it "evaluates addition" do
      node = Node::BinaryOp.new(
        Node::Integer.new(1),
        :plus,
        Node::Integer.new(2)
      )
      expect(subject.evaluate(node)).to eq(3)
    end

    it "evaluates subtraction" do
      node = Node::BinaryOp.new(
        Node::Integer.new(5),
        :minus,
        Node::Integer.new(3)
      )
      expect(subject.evaluate(node)).to eq(2)
    end

    it "evaluates multiplication" do
      node = Node::BinaryOp.new(
        Node::Integer.new(3),
        :asterisk,
        Node::Integer.new(4)
      )
      expect(subject.evaluate(node)).to eq(12)
    end

    it "evaluates division" do
      node = Node::BinaryOp.new(
        Node::Integer.new(10),
        :slash,
        Node::Integer.new(2)
      )
      expect(subject.evaluate(node)).to eq(5)
    end

    it "evaluates nested operations" do
      # (2 + 3) * 4
      node = Node::BinaryOp.new(
        Node::BinaryOp.new(
          Node::Integer.new(2),
          :plus,
          Node::Integer.new(3)
        ),
        :asterisk,
        Node::Integer.new(4)
      )
      expect(subject.evaluate(node)).to eq(20)
    end

    it "raises error for unknown operator" do
      node = Node::BinaryOp.new(
        Node::Integer.new(1),
        :unknown,
        Node::Integer.new(2)
      )
      expect { subject.evaluate(node) }.to raise_error("Unknown operator: unknown")
    end
  end
end
