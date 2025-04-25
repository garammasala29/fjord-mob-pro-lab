require_relative '../lib/parser_step3'

RSpec.describe ParserStep3 do
  subject { described_class }

  describe ".eval" do
    it "respects operator precedence" do
      expect(subject.eval("2 + 3 * 4")).to eq(14)  # 3 * 4 = 12, 2 + 12 = 14
      expect(subject.eval("10 - 4 / 2")).to eq(8)  # 4 / 2 = 2, 10 - 2 = 8
    end

    it "handles multiplication and division with left association" do
      expect(subject.eval("20 / 2 / 5")).to eq(2)  # (20 / 2) / 5 = 10 / 5 = 2
      expect(subject.eval("2 * 3 * 4")).to eq(24)  # (2 * 3) * 4 = 6 * 4 = 24
    end

    it "handles mixed precedence operations" do
      expect(subject.eval("2 * 3 + 4 * 5")).to eq(26)  # (2 * 3) + (4 * 5) = 6 + 20 = 26
      expect(subject.eval("10 + 5 * 2 - 3")).to eq(17) # 10 + (5 * 2) - 3 = 10 + 10 - 3 = 17
    end

    it "handles complex expressions" do
      expect(subject.eval("2 + 3 * 4 - 5 / 5 + 1")).to eq(14)
      # 3 * 4 = 12, 5 / 5 = 1
      # 2 + 12 - 1 + 1 = 14
    end

    it "raises error on empty input" do
      expect { subject.eval("") }.to raise_error(RuntimeError)
    end

    it "raises error on invalid syntax" do
      expect { subject.eval("2 +") }.to raise_error(RuntimeError)
      expect { subject.eval("* 3") }.to raise_error(RuntimeError)
    end
  end
end
