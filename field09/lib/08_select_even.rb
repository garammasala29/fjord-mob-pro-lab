# 配列から偶数のみの配列を返す関数`select(&:even?)`と同じ
# Usage:
#   rec_select_even([1, 2, 3, 4]) #=> [2, 4]
#   rec_select_even([]) #=> []

def rec_select_even(ary)
  return [] if ary.empty?

  num = ary[-1]
  num.even? ? rec_select_even(ary[0..-2]) << num : rec_select_even(ary[0..-2])
end
