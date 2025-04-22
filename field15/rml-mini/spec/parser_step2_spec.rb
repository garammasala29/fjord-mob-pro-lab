require_relative "../lib/parser_step2"

RSpec.describe ParserStep2 do
  subject { described_class }

  describe ".eval" do
    it "evaluates simple addition" do
      expect(subject.eval("1 + 2")).to eq(3)
    end

    it "evaluates left-to-right without precedence" do
      expect(subject.eval("2 + 3 * 4")).to eq(20) # ((2 + 3) * 4)
      expect(subject.eval("20 / 2 - 3")).to eq(7) # ((20 / 2) - 3)
    end

    it "supports multiple chained operations" do
      expect(subject.eval("1 + 2 + 3 + 4")).to eq(10)
    end

    it "supports all four operations" do
      expect(subject.eval("10 - 2 * 3 + 1")).to eq(25) # (((10 - 2) * 3) + 1)
    end

    it "raises on unknown operator" do
      expect { subject.eval("1 ^ 2") }.to raise_error(/Unknown character/)
    end
  end
end
