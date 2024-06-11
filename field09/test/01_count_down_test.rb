require 'minitest/autorun'
require_relative '../lib/01_count_down.rb'

class TestClass < Minitest::Test
  def test_rec_count_down_when_argument_is_5
    expected = <<~OUTPUT
      5
      4
      3
      2
      1
      0
    OUTPUT

    assert_output(expected) { rec_count_down(5) }
  end

  def test_rec_count_down_when_argument_is_1
    expected = <<~OUTPUT
      1
      0
    OUTPUT

    assert_output(expected) { rec_count_down(1) }
  end

  def test_rec_count_down_when_argument_is_0
    expected = <<~OUTPUT
      0
    OUTPUT

    assert_output(expected) { rec_count_down(0) }
  end
end
