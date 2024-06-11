# 0から与えられた引数までカウントアップするメソッド
# Usage
#   rec_count_up(5)
#     0
#     1
#     2
#     3
#     4
#     5

def rec_count_up(n, count = 0)
  return if count > n
  puts count
  count += 1
  rec_count_up(n, count)
end
