# Q1.
# 次の動作をする A1 class を実装する
# - "//" を返す "//"メソッドが存在すること
class A1
  define_method(:'//') do
    '//'
  end
end

# Q2.
# 次の動作をする A2 class を実装する
# - 1. "SmartHR Dev Team"と返すdev_teamメソッドが存在すること
# - 2. initializeに渡した配列に含まれる値に対して、"hoge_" をprefixを付与したメソッドが存在すること
# - 2で定義するメソッドは下記とする
#   - 受け取った引数の回数分、メソッド名を繰り返した文字列を返すこと
#   - 引数がnilの場合は、dev_teamメソッドを呼ぶこと
# - また、2で定義するメソッドは以下を満たすものとする
#   - メソッドが定義されるのは同時に生成されるオブジェクトのみで、別のA2インスタンスには（同じ値を含む配列を生成時に渡さない限り）定義されない
class A2
  def dev_team
    "SmartHR Dev Team"
  end

  def initialize(array)
    array.each do |ary|
      name = "hoge_#{ary}"
      self.define_singleton_method(name) do |arg = nil|
        if arg.nil?
          dev_team
        else
          name * arg
        end
      end
    end
  end
end

# ary = ['foo', 'bar', 'baz']
# a2 = A2.new(ary)
# a2.hoge_foo(3) => 'hoge_foohoge_foo_hogefoo'
# a2.hoge_foo => 'SmartHR Dev Team'

# Q3.
# 次の動作をする OriginalAccessor モジュール を実装する
# - OriginalAccessorモジュールはincludeされたときのみ、my_attr_accessorメソッドを定義すること
# - my_attr_accessorはgetter/setterに加えて、boolean値を代入した際のみ真偽値判定を行うaccessorと同名の?メソッドができること
module OriginalAccessor
  def self.included(klass)
    values = {}

    klass.define_singleton_method(:my_attr_accessor) do |attr|
      klass.define_method(attr) do
        values[attr]
      end

      klass.define_method("#{attr}=") do |value|
        values[attr] = value

        if value.is_a?(TrueClass) || value.is_a?(FalseClass)
          klass.define_method("#{attr}?") do
            !!value
          end
        end
      end
    end
  end
end

class User
  include OriginalAccessor
  my_attr_accessor :name
  my_attr_accessor :age
  my_attr_accessor :adult
end

# taro = User.new
# # setter
# taro.name = 'taro'
# taro.age = 23
# taro.is_adult = true
# taro.is_adult = false
# taro.is_adult? # => false

# taro.name #=> taro
# taro.age #=> 2
