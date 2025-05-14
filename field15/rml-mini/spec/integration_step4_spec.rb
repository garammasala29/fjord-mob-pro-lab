# spec/integration_spec.rb
require_relative "../lib/parser_step4"
require_relative "../lib/evaluator"

RSpec.describe "Integration" do
  let(:parser) { ParserStep4 }
  let(:evaluator) { Evaluator.new }

  def evaluate(input)
    ast = parser.parse(input)
    evaluator.evaluate(ast)
  end

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

  it "correctly evaluates complex expressions" do
    expect(evaluate("(7 + 3) * (2 + (8 / 4))")).to eq(40)
    expect(evaluate("10 - (4 + 2) * 3")).to eq(-8)
  end
end
