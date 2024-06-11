require 'minitest/autorun'
require_relative '../lib/08_select_even.rb'

class TestClass < Minitest::Test
  def test_select_even_when_empty_ary
    assert_equal [], rec_select_even([])
  end

  def test_select_even1
    assert_equal [0, -100], rec_select_even([1, 0, 23, -100])
  end

  def test_select_even2
    assert_equal [2], rec_select_even([1, 2, 3])
  end

  def test_select_even3
    assert_equal [], rec_select_even([1, 3, 5])
  end
end
