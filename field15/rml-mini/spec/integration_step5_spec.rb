require_relative "../lib/parser_step5"
require_relative "../lib/evaluator"

RSpec.describe "Integration" do
  let(:parser) { ParserStep5 }
  let(:evaluator) { Evaluator.new }

  def evaluate(input)
    ast = parser.parse(input)
    evaluator.evaluate(ast)
  end

  it "変数代入と参照を正しく処理する" do
    expect(evaluate("x = 10")).to eq(10)
    expect(evaluate("x")).to eq(10)
    expect(evaluate("x + 5")).to eq(15)
    expect(evaluate("y = x * 2")).to eq(20)
    expect(evaluate("y")).to eq(20)
  end

  it "未定義の変数でエラーを発生させる" do
    expect { evaluate("z") }.to raise_error(/未定義の変数/)
  end
end
