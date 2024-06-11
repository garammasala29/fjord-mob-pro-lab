require 'minitest/autorun'
require_relative '../lib/03_factorial.rb'

class TestClass < Minitest::Test
  def test_factorial_5
    assert_equal 120, rec_factorial(5)
  end

  def test_factorial_1
    assert_equal 1, rec_factorial(1)
  end

  def test_factorial_8
    assert_equal 40320, rec_factorial(8)
  end

  def test_factorial_0
    assert_equal 1, rec_factorial(0)
  end
end
