# spec/parser_step4_spec.rb
require_relative "../lib/parser_step4"

RSpec.describe ParserStep4 do
  subject { described_class }

  describe ".eval" do
    context "when using basic operations" do
      it "evaluates addition" do
        expect(subject.eval("1 + 2")).to eq(3)
      end

      it "evaluates subtraction" do
        expect(subject.eval("5 - 3")).to eq(2)
      end

      it "evaluates multiplication" do
        expect(subject.eval("3 * 4")).to eq(12)
      end

      it "evaluates division" do
        expect(subject.eval("10 / 2")).to eq(5)
      end
    end

    context "when respecting operator precedence" do
      it "evaluates multiplication before addition" do
        expect(subject.eval("2 + 3 * 4")).to eq(14)
      end

      it "evaluates division before subtraction" do
        expect(subject.eval("10 - 4 / 2")).to eq(8)
      end
    end

    context "when using parentheses" do
      it "evaluates expressions within parentheses first" do
        expect(subject.eval("(2 + 3) * 4")).to eq(20)
        expect(subject.eval("2 * (3 + 4)")).to eq(14)
      end

      it "handles nested parentheses" do
        expect(subject.eval("2 * (3 + (5 - 2))")).to eq(12)
        expect(subject.eval("((7 - 3) + 2) * 3")).to eq(18)
      end

      it "handles parentheses with operator precedence" do
        expect(subject.eval("10 - (4 + 2) * 3")).to eq(-8)
        expect(subject.eval("(10 - 4 + 2) * 3")).to eq(24)
      end
    end

    context "when handling complex expressions" do
      it "evaluates complex expressions with parentheses" do
        expect(subject.eval("(8 - 4) / (1 + 1)")).to eq(2)
        expect(subject.eval("(7 + 3) * (2 + (8 / 4))")).to eq(40)
      end

      it "handles multiple operations and parentheses" do
        expect(subject.eval("1 + 2 * 3 + (4 * 5)")).to eq(27)
        expect(subject.eval("(1 + 2) * (3 + 4) - 5")).to eq(16)
      end
    end

    context "when handling errors" do
      it "raises error on unbalanced parentheses" do
        expect { subject.eval("(2 + 3") }.to raise_error(RuntimeError)
        expect { subject.eval("2 + 3)") }.to raise_error(RuntimeError)
      end

      it "raises error on empty parentheses" do
        expect { subject.eval("()") }.to raise_error(RuntimeError)
      end

      it "raises error on missing operand" do
        expect { subject.eval("2 +") }.to raise_error(RuntimeError)
        expect { subject.eval("(2 +)") }.to raise_error(RuntimeError)
      end
    end
  end
end
