require 'minitest/autorun'
require_relative '../lib/02_count_up.rb'

class TestClass < Minitest::Test
  def test_rec_count_up_when_argument_is_5
    expected = <<~OUTPUT
      0
      1
      2
      3
      4
      5
    OUTPUT

    assert_output(expected) { rec_count_up(5) }
  end

  def test_rec_count_up_when_argument_is_1
    expected = <<~OUTPUT
      0
      1
    OUTPUT

    assert_output(expected) { rec_count_up(1) }
  end

  def test_rec_count_up_when_argument_is_0
    expected = <<~OUTPUT
      0
    OUTPUT

    assert_output(expected) { rec_count_up(0) }
  end
end
