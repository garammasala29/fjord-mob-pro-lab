require_relative '../lib/suica.rb'

RSpec.describe Suica do
  let(:suica) { Suica.new(25, :male) }

  describe '#charge' do
    context '正常系' do
      it '100円以上の金額をチャージできること' do
        suica.charge(100)

        expect(suica.balance).to eq 100
      end
    end

    context '異常系' do
      it '100円未満を入力したらエラーになること' do
        expect{ suica.charge(99) }.to raise_error Suica::MinimumAmountError
        expect{ suica.charge(-1) }.to raise_error Suica::MinimumAmountError
      end

      it '小数を入力したらエラーになること' do
        expect{ suica.charge(0.1) }.to raise_error Suica::FloatAmountError
      end
    end
  end

  describe '#balance' do
    it '120円のコーラを購入したら残高が120減ること' do
      suica.charge(1000)
      suica.pay(120)

      expect(suica.balance).to eq 880
    end
  end
end
