source "https://rubygems.org"

# Railsの最新版（edge）を使用する場合: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# Railsの元々のアセットパイプライン [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Active Recordのデータベースとしてpostgresqlを使用
gem "pg", "~> 1.1"
# Pumaウェブサーバーを使用 [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# JavaScriptのバンドル(結合)とトランスパイル(変換) [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# HotwireのSPA風ページアクセラレータ [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwireの控えめなJavaScriptフレームワーク [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# JSON APIを簡単に構築 [https://github.com/rails/jbuilder]
gem "jbuilder"
# 本番環境でAction Cableを実行するためにRedisアダプタを使用
# gem "redis", ">= 4.0.1"
gem "devise"
# Redisでより高度なデータ型を使用するためにKredisを使用 [https://github.com/rails/kredis]
# gem "kredis"
# Active Modelのhas_secure_passwordを使用 [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
# Windowsにはzoneinfoファイルが含まれていないため、tzinfo-data gemをバンドル
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "redis"
# キャッシュによる起動時間の短縮; config/boot.rbで必要
gem "bootsnap", require: false
gem "devise_invitable", "~> 2.0"
# Active Storageのバリアントを使用 [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
gem "devise-two-factor"
gem "rotp"
gem "rqrcode"
gem "devise-pwned_password"
gem "pundit"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "geocoder"

group :development, :test do
  # 参照: https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # セキュリティ脆弱性の静的解析 [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Rubyスタイル [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  # 例外ページでコンソールを使用 [https://github.com/rails/web-console]
  gem "web-console"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "i18n-tasks"
end

group :test do
  # システムテストを使用 [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "simplecov", require: false
end

gem "stripe", ">= 8.0"
