require_relative "../lib/parser_step1"

RSpec.describe ParserStep1 do
  subject { described_class.eval(expr) }

  describe ".eval" do
    context "when adding two numbers" do
      let(:expr) { "1 + 2" }

      it { is_expected.to eq(3) }
    end

    context "when subtracting two numbers" do
      let(:expr) { "5 - 3" }

      it { is_expected.to eq(2) }
    end

    context "when multiplying two numbers" do
      let(:expr) { "3 * 4" }

      it { is_expected.to eq(12) }
    end

    context "when dividing two numbers" do
      let(:expr) { "10 / 2" }

      it { is_expected.to eq(5) }
    end

    context "when using an unknown operator" do
      let(:expr) { "2 ^ 3" }

      it { expect { subject }.to raise_error("Unknown operator: ^") }
    end
  end
end
