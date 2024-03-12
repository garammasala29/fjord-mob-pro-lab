class Drink
  attr_reader :name, :price

  def initialize(name, price)
    @name = name
    @price = price
  end

  def eql?(other)
    self.name == other.name && self.price == other.price
  end

  def hash
    [name, price].hash
  end
end
