# 非負整数に対する階乗の計算をする
# ex) 5! = 5 * 4 * 3 * 2 * 1 = 120
#
# Usage: rec_factorial(5) #=> 120

def rec_factorial(n)
  return 1 if n <= 0

  p n * rec_factorial(n-1)
end

rec_factorial(5)
