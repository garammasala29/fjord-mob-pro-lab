require 'minitest/autorun'
require_relative '../lib/10_append.rb'

class TestClass < Minitest::Test
  def test_append1
    assert_equal [[1, 2], [1, 2, 3], [1, 2, 3, 4]], rec_append(1, [[2], [2, 3], [2, 3, 4]])
  end
end
