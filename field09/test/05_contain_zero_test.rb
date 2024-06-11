require 'minitest/autorun'
require_relative '../lib/05_contain_zero.rb'

class TestClass < Minitest::Test
  def test_contain_zero_when_empty_ary_is_false
    refute rec_contain_zero?([])
  end

  def test_contain_zero_is_true
    assert rec_contain_zero?([1, 2, 3, 0, 100])
  end

  def test_contain_zero_is_true
    refute rec_contain_zero?([1, 2, 3, 100])
  end
end
