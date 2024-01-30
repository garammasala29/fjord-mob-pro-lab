# Rackミドルウェア
class GoodBye
  def initialize(app)
    @app = app
  end

  def call(env)
    code, headers, body = @app.call(env)
    p "===== GoodBye! ====="
    return [code, headers, body]
  end
end

# テスト用アプリ（テスト時rackupのときだけ使い、組み込むときはコメントアウト）
# App = lambda do |env|
#   [200, {"Content-Type" => "text/html"}, ["GoodBye, Rack world!"]]
# end
Rails.application.config.middleware.use GoodBye

# use ActionDispatch::HostAuthorization
# use Rack::Sendfile
# use ActionDispatch::Static
# use ActionDispatch::Executor
# use ActionDispatch::ServerTiming
# use ActiveSupport::Cache::Strategy::LocalCache::Middleware
# use Rack::Runtime
# use Rack::MethodOverride
# use ActionDispatch::RequestId
# use ActionDispatch::RemoteIp
# use Sprockets::Rails::QuietAssets
# use Rails::Rack::Logger
# use ActionDispatch::ShowExceptions
# use WebConsole::Middleware
# use ActionDispatch::DebugExceptions
# use ActionDispatch::ActionableExceptions
# use ActionDispatch::Reloader
# use ActionDispatch::Callbacks
# use ActiveRecord::Migration::CheckPending
# use ActionDispatch::Cookies
# use ActionDispatch::Session::CookieStore
# use ActionDispatch::Flash
# use ActionDispatch::ContentSecurityPolicy::Middleware
# use ActionDispatch::PermissionsPolicy::Middleware
# use Rack::Head
# use Rack::ConditionalGet
# use Rack::ETag
# use Rack::TempfileReaper
# use GoodBye
# use Hello
# run RackPractice::Application.routes
