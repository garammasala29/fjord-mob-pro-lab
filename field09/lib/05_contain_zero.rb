# 配列に 0(int)が含まれるかどうかを判定するメソッド
# Usage:
#   rec_contain_zero?([3, 2, 1, 0]) #=> true
#   rec_contain_zero?([2, 4, 6]) #=> false

def rec_contain_zero?(ary)
  return false if ary.empty?

  num = ary[-1]
  return true if num == 0

  rec_contain_zero?(ary[0..-2])
end

# ary = [3,2,1]
# p rec_contain_zero?(ary)
# p ary
