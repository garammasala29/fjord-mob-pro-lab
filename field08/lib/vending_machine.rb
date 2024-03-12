require_relative './drink.rb'

class VendingMachine
  def initialize()
    @drinks = 5.times.map{ Drink.new('コーラ', 120) }
  end

  def drink_information
    drink_information = []
    @drinks.tally.each do |drink, stock|
      drink_status = {name:drink.name, price:drink.price, stock:}
      drink_information << drink_status
    end
    drink_information
  end

  def in_stock?
    coke = drink_information.find { |drink_status| drink_status[:name] == 'コーラ' }
    return false if coke.nil?
    coke[:stock] > 0
    # !(coke.nil? || coke[:stock] <= 0)
  end
end

# [{name: 'コーラー', price: 120, stock: 0}, {}]
