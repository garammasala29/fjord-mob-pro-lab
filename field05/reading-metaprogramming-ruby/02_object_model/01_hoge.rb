# Q1.
# Hogeクラスは次の仕様を持つ
# "hoge" という文字列の定数Hogeを持つ
# "hoge" という文字列を返すhogehogeメソッドを持つ
# HogeクラスのスーパークラスはStringである
# 自身が"hoge"という文字列である時（HogeクラスはStringがスーパークラスなので、当然自身は文字列である）、trueを返すhoge?メソッドが定義されている

class Hoge < String
  Hoge = 'hoge'

  def hogehoge
    Hoge
  end

  def hoge?
    self == Hoge
  end
end

# Q2.
# 次に挙げるクラスのいかなるインスタンスからも、hogeメソッドが呼び出せるようにする
# それらのhogeメソッドは、全て"hoge"という文字列を返す
classes = [String, Integer, Numeric, Class, Hash, TrueClass]

classes.each do |klass|
  klass.define_method(:hoge) do
    'hoge'
  end
end
