require 'minitest/autorun'
require_relative '../lib/07_length.rb'

class TestClass < Minitest::Test
  def test_length_when_empty_ary
    assert_equal 0, rec_length([])
  end

  def test_length1
    assert_equal 4, rec_length([1, 0, 23, -100])
  end

  def test_length2
    assert_equal 3, rec_length([1, 2, 3])
  end

  def test_length3
    assert_equal 10, rec_length([*1..10])
  end
end
