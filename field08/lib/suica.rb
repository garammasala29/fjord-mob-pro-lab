class Suica
  class MinimumAmountError < StandardError; end
  class FloatAmountError < StandardError; end
  class NegativeAmountError < StandardError; end
  class InsufficientAmountError < StandardError; end

  attr_reader :balance

  def initialize
    @balance = 0
  end

  def charge(amount)
    raise FloatAmountError, '小数ですよ！' if amount.to_i != amount
    raise MinimumAmountError, '100円未満ですよ！' if amount < 100

    @balance += amount
  end

  def pay(amount)
    raise FloatAmountError, '小数ですよ！' if amount.to_i != amount
    raise NegativeAmountError, '負の数ですよ！' if amount < 0
    raise InsufficientAmountError unless pay?(amount)

    @balance -= amount
  end

  private

  def pay?(amount)
    @balance >= amount
  end
end
