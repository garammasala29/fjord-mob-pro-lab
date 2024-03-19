require_relative '../lib/vending_machine.rb'

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }

  describe '#drink_information' do
    it '格納したドリンク情報が取得できること' do
      expect(vending_machine.drink_information).to eq({"おしるこ"=>{:price=>80, :stock=>5}, "コーラ"=>{:price=>120, :stock=>5}, "コーンポタージュ"=>{:price=>180, :stock=>5}})
    end
  end

  describe '#in_stock?' do
    it '在庫が1つ以上である場合 true を返すこと' do
      expect(vending_machine.in_stock?).to be true
    end

    it '在庫が0のである場合 falseを返すこと' do
      vending_machine.instance_variable_set(:@drinks, [])

      expect(vending_machine.in_stock?).to be false
    end
  end

  describe '#buy' do
    let(:suica) { double('suica') }

    before do
      allow(suica).to receive(:pay).and_return nil
    end

    it '購入すると在庫が1つ減ること' do
      vending_machine.buy('コーラ', suica)
      coke = vending_machine.drink_information['コーラ']

      expect(coke[:stock]).to be 4
    end

    it '購入すると商品金額分売り上げが増えること' do
      vending_machine.buy('コーラ', suica)

      expect(vending_machine.sales).to be 120
    end
  end

  describe '#in_stock_list' do
    let(:five_cokes) { 5.times.map{ Drink.new('コーラ', 120) }}
    let(:corn_potage) { Drink.new('コーンポタージュ', 180) }

    it '在庫がある商品のリストが取得できること' do
      vending_machine.instance_variable_set(:@drinks, [*five_cokes, corn_potage])

      expect(vending_machine.in_stock_list).to eq ['コーラ', 'コーンポタージュ']
    end
    it '在庫がある商品が存在しないときは空のリストが取得できること' do
      vending_machine.instance_variable_set(:@drinks, [])

      expect(vending_machine.in_stock_list).to eq []
    end
  end
end
