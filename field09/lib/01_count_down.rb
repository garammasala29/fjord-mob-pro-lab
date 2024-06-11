# 与えられた引数から0までカウントダウンするメソッド
# Usage
#   rec_count_down(5)
#     5
#     4
#     3
#     2
#     1
#     0

def rec_count_down(n)
  return if n < 0
  puts n
  n -= 1
  rec_count_down(n)
end
