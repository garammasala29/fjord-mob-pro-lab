# 配列の要素の長さを返すメソッド
# Usage:
#    rec_length([1, 2, 3]) #=> 3
#    rec_length([]) #=> 0

def rec_length(ary)
  return 0 if ary.empty?

  1 + rec_length(ary[0..-2])
end
