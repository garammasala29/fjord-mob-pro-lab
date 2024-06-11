require 'minitest/autorun'
require_relative '../lib/04_double_factorial.rb'

class TestClass < Minitest::Test
  def test_double_factorial_5
    assert_equal 15, rec_double_factorial(5)
  end

  def test_double_factorial_8
    assert_equal 384, rec_double_factorial(8)
  end

  def test_double_factorial_1
    assert_equal 1, rec_double_factorial(1)
  end

  def test_double_factorial_0
    assert_equal 1, rec_double_factorial(0)
  end
end
