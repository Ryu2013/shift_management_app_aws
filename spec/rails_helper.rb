require 'simplecov'

SimpleCov.start 'rails' do
  # ここに add_filter を追加します
  add_filter 'app/jobs/application_job.rb'
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'app/channels/application_cable/channel.rb'
end
# このファイルは `rails generate rspec:install` を実行したときに spec/ にコピーされます
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# 環境が production の場合、データベースの切り詰めを防ぐ
abort("The Rails environment is running in production mode!") if Rails.env.production?
# `.rspec` ファイルに `--require rails_helper` がある場合は、下の行のコメントを外してください
# （マイグレーションが実行されていないために Rails のジェネレーターがクラッシュするのを避けます）
# return unless Rails.env.test?
require 'rspec/rails'

# rootからspec/support以下のrbファイルをすべて読み込む。これにより、いちいちrequireしなくてよくなる
# sort.eachで読み込み順序が安定化する
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # ActiveRecord または ActiveRecord フィクスチャを使用していない場合はこの行を削除してください
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]
  config.before(:each) do
    # ログファイルを強制的にサイズ0（空）にする
    File.truncate('log/test.log', 0)
    Rails.logger.info("🧹 Log cleared for new test")
  end
  config.before(:each) do |example|
    # ログに目立つ区切り線と、これから実行するテスト名を出力
    Rails.logger.info("\n\n" + "=" * 80)
    Rails.logger.info("🚀 START TEST: #{example.full_description}")
    Rails.logger.info("=" * 80 + "\n")
  end
  config.include Devise::Test::IntegrationHelpers, type: :request
  # ActiveRecord を使用していないか、各例をトランザクション内で実行したくない場合は、
  # 以下の行を削除するか true の代わりに false を設定してください。
  config.use_transactional_fixtures = true

  # Capybara.server_host = '0.0.0.0' Capybara.server_port = 3001はwebコンテナ上の自分から見たURL。
  # 自分のどのip.portでSeleniumサーバーを待つかを指定する。
  # app_hostはseleniumコンテナから見たwebサーバーのURLを指定する。
  # 同一composeネットワーク内のサービス名で指定できる。
  config.before(:each, type: :system) do
      driven_by :selenium, using: :headless_chrome do |options|
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
    end
    Capybara.ignore_hidden_elements = false
  end

  config.include FactoryBot::Syntax::Methods
  # バックトレースから Rails の gem の行をフィルタリングします。
  config.filter_rails_from_backtrace!
  # 任意の gem も以下のようにフィルタできます:
  # config.filter_gems_from_backtrace("gem name")
end
