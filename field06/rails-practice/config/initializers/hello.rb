# Rackミドルウェア
class Hello
  def initialize(app)
    @app = app
  end

  def call(env)
    code, headers, body = @app.call(env)
    p "===== Hello! ====="
    return [code, headers, body]
  end
end

# テスト用アプリ（テスト時rackupのときだけ使い、組み込むときはコメントアウト）
# App = lambda do |env|
#   [200, {"Content-Type" => "text/html"}, ["Hello, Rack world!"]]
# end
Rails.application.config.middleware.use Hello
