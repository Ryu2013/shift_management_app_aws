require "active_support/core_ext/integer/time"

Rails.application.configure do
  # ここで指定した設定は config/application.rb より優先されます。

  # リクエスト間でコードは再読み込みされません。
  config.enable_reloading = false

  # 起動時にコードを eager load します。これにより Rails とアプリの大部分がメモリに読み込まれ、
  # スレッド化されたウェブサーバや copy-on-write に依存するサーバのパフォーマンスが向上します。
  # Rake タスクはパフォーマンスのため自動的にこのオプションを無視します。
  config.eager_load = true

  # 詳細なエラーレポートは無効化され、キャッシュは有効になっています。
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # ENV["RAILS_MASTER_KEY"], config/master.key, または config/credentials/production.key のような環境キーに
  # マスターキーが用意されていることを保証します。このキーは資格情報（や他の暗号化ファイル）を復号するために使用されます。
  # config.require_master_key = true

  # public/ から静的ファイルを提供するのを無効にし、代わりに NGINX/Apache に依存します。
  # config.public_file_server.enabled = false

  # プリプロセッサを使って CSS を圧縮します。
  # config.assets.css_compressor = :sass

  # プリコンパイルされたアセットが見つからない場合にアセットパイプラインへフォールバックしないようにします。
  config.assets.compile = false

  # アセットサーバーから画像、スタイルシート、JavaScript を配信する機能を有効にします。
  # config.asset_host = "http://assets.example.com"

  # サーバがファイル送信に使用するヘッダーを指定します。
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # アップロードされたファイルをローカルファイルシステムに保存します（オプションは config/storage.yml を参照）。
  config.active_storage.service = :local

  # Action Cable をメインプロセスやドメインの外にマウントします。
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # アプリへのすべてのアクセスが SSL 終端を行うリバースプロキシ経由で行われていると仮定します。
  # Strict-Transport-Security とセキュアクッキーのために config.force_ssl と併用できます。
  # config.assume_ssl = true

  # アプリへのすべてのアクセスを SSL に強制し、Strict-Transport-Security を使用し、セキュアクッキーを有効にします。
  config.force_ssl = false

  # デフォルトのヘルスチェックエンドポイントに対する HTTP→HTTPS のリダイレクトをスキップします。
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # デフォルトで STDOUT にログを出力します
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # すべてのログ行に次のタグを先頭につけます。
  config.log_tags = [ :request_id ]

  # 「info」はシステム運用に関する一般的で有用な情報を含みますが、個人情報の曝露を避けるためにログ量を抑えます。
  # すべて記録したい場合はレベルを "debug" に設定してください。
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # 本番環境では別のキャッシュストアを使用します。
  # config.cache_store = :mem_cache_store

  # Active Job に実際のキューバックエンドを使用します（環境ごとにキューを分ける）。
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "app_production"

  # Action Controller のキャッシュが有効でも、Action Mailer テンプレートに対するキャッシュを無効にします。
  config.action_mailer.perform_caching = false

  # 不正なメールアドレスを無視して、メール配信エラーを発生させません。
  # 配信エラーを発生させたい場合は true に設定し、メールサーバを即時配信するよう設定してください。
  # config.action_mailer.raise_delivery_errors = false

  # I18n のロケールフォールバックを有効にします（翻訳が見つからない場合に I18n.default_locale にフォールバックします）。
  config.i18n.fallbacks = true

  # 非推奨の警告をログに記録しません。
  config.active_support.report_deprecations = false

  # マイグレーション後にスキーマをダンプしません。
  config.active_record.dump_schema_after_migration = false

  # 本番環境では検査に :id のみを使用します。
  config.active_record.attributes_for_inspect = [ :id ]
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              "smtp.sendgrid.net",
    port:                 587,
    domain:               "care-shift.jp",
    user_name:            "apikey",
    password:             Rails.application.credentials.dig(:sendgrid, :api_key),
    authentication:       :plain,
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = { host: "shift-management-app-f04c8ce17ef9.herokuapp.com", protocol: "https" }

  # Action Cable の接続先と許可元（Heroku のアプリ名に合わせる）
  config.action_cable.url = "wss://shift-management-app-f04c8ce17ef9.herokuapp.com/cable"
  config.action_cable.allowed_request_origins = [
    "https://shift-management-app-f04c8ce17ef9.herokuapp.com"
  ]
end
