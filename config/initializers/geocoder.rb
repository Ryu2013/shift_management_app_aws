Geocoder.configure(
  # ジオコーディングのオプション
  # timeout: 3,                 # ジオコーディングサービスのタイムアウト（秒）
  lookup: :google,         # ジオコーディングサービスの名前（シンボル）
  # ip_lookup: :ipinfo_io,      # IPアドレスジオコーディングサービスの名前（シンボル）
  # language: :en,              # ISO-639言語コード
  use_https: true,           # リクエストにHTTPSを使用するか？（サポートされている場合）
  # http_proxy: nil,            # HTTPプロキシサーバー（user:pass@host:port）
  # https_proxy: nil,           # HTTPSプロキシサーバー（user:pass@host:port）
  api_key: Rails.application.credentials.dig(:google, :maps_api_key),              # ジオコーディングサービスのAPIキー
  # cache: nil,                 # キャッシュオブジェクト（#[]、#[]=、#delに応答する必要がある）

  # デフォルトでレスキューすべきでない例外
  # （カスタムエラーハンドリングを実装したい場合）
  # SocketErrorとTimeout::Errorをサポート
  # always_raise: [],

  # 計算のオプション
  units: :km,                 # :kmはキロメートル、:miはマイル
  # distances: :linear          # :sphericalまたは:linear

  # キャッシュの設定
  # cache_options: {
  #   expiration: 2.days,
  #   prefix: 'geocoder:'
  # }
)

# テスト環境ではGoogleに通信せず、偽のデータを返す設定
if Rails.env.test?
  Geocoder.configure(lookup: :test, ip_lookup: :test)

  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        "coordinates"  => [ 35.6895, 139.6917 ],
        "address"      => "Tokyo, Japan",
        "state"        => "Tokyo",
        "country"      => "Japan",
        "country_code" => "JP"
      }
    ]
  )
end
