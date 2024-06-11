require 'minitest/autorun'
require_relative '../lib/09_count.rb'

class TestClass < Minitest::Test
  def test_count_when_empty_ary
    assert_equal 0, rec_count([], 1)
  end

  def test_count1
    assert_equal 3, rec_count([1, 2, 3, 3, 3], 3)
  end

  def test_count2
    assert_equal 0, rec_count(['a', 'b', 'c'], 100)
  end

  def test_count3
    assert_equal 2, rec_count(['a', 'b', 'c', 'c', 'd'], 'c')
  end
end
