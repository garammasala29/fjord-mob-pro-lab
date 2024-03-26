require_relative './drink.rb'
class VendingMachine
  PRICE_TABLE = {
    'コーラ' => 120,
    'おしるこ' => 80,
    'コーンポタージュ' => 180
  }

  DEFAULT_QUANTITY = 5

  attr_reader :sales, :sales_history

  def initialize()
    @drinks = []
    set_drinks(DEFAULT_QUANTITY)
    @sales = 0
    @sales_history = {}
  end

  def drink_information
    drink_information = {}
    @drinks.tally.each do |drink, stock|
      drink_information[drink.name] = {price: drink.price, stock:}
    end

    drink_information
  end

  def in_stock?
    coke = drink_information['コーラ']
    return false if coke.nil?

    coke[:stock] > 0
  end

  def in_stock_list
    @drinks.map(&:name).uniq
  end

  def buy(name, suica)
    return unless in_stock?

    @drinks.shift
    price = drink_information[name][:price]
    suica.pay(price)
    @sales += price
    add_sales_history(name, suica.age, suica.gender)

  rescue => e
    puts e.message
  end

  private

  def set_drinks(quantity)
    PRICE_TABLE.each do |name, price|
      quantity.times { @drinks << Drink.new(name, price) }
    end
  end

  def add_sales_history(name, age, gender)
    (@sales_history[name] ||= []) << [age, gender, Time.now]
  end
end
