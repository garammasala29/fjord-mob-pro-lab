# 配列を受け取り、引数で与えられたオブジェクトがいくつあるかを返す
# Usage:
#  rec_count([1, 1, 2, 3, 1], 1) #=> 3
#  rec_count([1, 1, 2, 3, 1], 'a') #=> 0
#  rec_count(['a', 'b', 'c', 'b'], 'c') #=> 1


def rec_count(ary, target_obj)
  return 0 if ary.empty?

  obj = ary[-1]
  obj == target_obj ? rec_count(ary[0..-2], target_obj) + 1 : rec_count(ary[0..-2], target_obj)
end

# p rec_count([1, 1, 2, 3, 1], 1) #=> 3
# p rec_count([1, 1, 2, 3, 1], 'a') #=> 0
# p rec_count(['a', 'b', 'c', 'b'], 'c') #=> 1
