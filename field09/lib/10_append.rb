# なんかこんな感じで2次元配列の各要素の先頭に引数nを加えた配列を返す
# Usage:
#   rec_append(1, [[2], [2, 3], [2, 3, 4]])
#   # => [[1, 2], [1, 2, 3], [1, 2, 3, 4]]


def rec_append(target, ary)
  return [] if ary.empty?

  target_ary = ary[-1]
  target_ary.unshift(target)
  rec_append(target, ary[0..-2]) << target_ary
end
