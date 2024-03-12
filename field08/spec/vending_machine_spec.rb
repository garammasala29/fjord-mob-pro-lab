require_relative '../lib/vending_machine.rb'

RSpec.describe VendingMachine do
  describe '#drink_information' do
    it '格納したドリンク情報が取得できること' do
      vending_machine = VendingMachine.new
      expect(vending_machine.drink_information).to eq [{name: 'コーラ', price: 120, stock: 5}]
    end
  end

  describe '#in_stock?' do
    it '在庫が1つ以上である場合 true を返すこと' do
      vending_machine = VendingMachine.new

      expect(vending_machine.in_stock?).to be true
    end

    it '在庫が0のである場合 falseを返すこと' do
      vending_machine = VendingMachine.new
      vending_machine.instance_variable_set(:@drinks, [])

      expect(vending_machine.in_stock?).to be false
    end
  end

  describe '#buy' do
    it '購入すると在庫が1つ減ること' do
      vending_machine = VendingMachine.new
      suica = double('suica')
      allow(suica).to receive(:pay).and_return nil
      vending_machine.buy('コーラ', suica)
      coke = drink_information.find { |drink_status| drink_status[:name] == 'コーラ' }
      expect(coke[:stock]).to be 4
    end
  end

end
