# 配列の要素を足し合わせる。
# 要素のデータ型は全てIntegerを想定。
#
# Usage:
#    rec_sum([10, 20, 30]) #=> 60
#    rec_sum([]) #=> 0

def rec_sum(ary)
  return 0 if ary.empty?

  first, *rest = ary
  first + rec_sum(rest)
end
