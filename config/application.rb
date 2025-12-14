require_relative "boot"

require "rails/all"

# Gemfileに記載されているgemを読み込みます。
# :test、:development、:productionなどで制限したgemも含まれます。
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # 元々生成されたRailsのバージョンに対する設定のデフォルト値を初期化します。
    config.load_defaults 8.1
    config.time_zone = "Tokyo"
    # `.rb`ファイルを含まない、またはリロード／イーガーロードしたくない
    # `lib`のサブディレクトリがあれば、`ignore`リストに追加してください。
    # 一般的には `templates`、`generators`、`middleware` などがあります。
    config.autoload_lib(ignore: %w[assets tasks])
    config.i18n.default_locale = :ja

    # PKをUUIDにする
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # アプリケーション、エンジン、railtiesの設定はここに記述します。
    #
    # これらの設定は、後で処理される config/environments の各環境ファイルで
    # 上書きできます。
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
