require 'minitest/autorun'
require_relative '../lib/06_sum.rb'

class TestClass < Minitest::Test
  def test_sum_when_empty_ary
    assert_equal 0, rec_sum([])
  end

  def test_sum1
    assert_equal -76, rec_sum([1, 0, 23, -100])
  end

  def test_sum2
    assert_equal -5050, rec_sum([*-100..-1])
  end

  def test_sum3
    assert_equal 55, rec_sum([*1..10])
  end
end
