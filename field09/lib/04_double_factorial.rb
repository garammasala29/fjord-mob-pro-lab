# 非負整数に対する二重階乗の計算をする
# ex1) 5!! = 5 * 3 * 1 = 15
#　ex2) 8!! = 8 * 6 * 4 * 2 = 384
# Usage: rec_factorial(5) #=> 120

def rec_double_factorial(n)
  return 1 if n <= 0

  n * rec_double_factorial(n - 2)
end
