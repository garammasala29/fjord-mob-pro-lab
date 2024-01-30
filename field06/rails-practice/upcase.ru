# Rackミドルウェア
class UpcaseAll
  def initialize(app)
    @app = app
  end

  def call(env)
    status_code, headers, body = @app.call(env)
    body.each{|part| part.upcase! }
    [status_code, headers, body]
  end
end
use UpcaseAll

# テスト用Rackアプリ
App = lambda do |env|
  [200, {"Content-Type" => "text/html"}, ["Hello, Rack world!"]]
end
run App
