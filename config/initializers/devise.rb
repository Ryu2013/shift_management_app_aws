# frozen_string_literal: true

# まだこのファイルを変更していないと仮定すると、以下の各設定オプションは
# デフォルト値に設定されています。いくつかはコメントアウトされており、他は
# されていません：コメントアウトされていない行は将来のアップグレードでの
# 破壊的な変更から設定を守るためのものです（つまり、将来のバージョンで
# Devise がデフォルト値を変更した場合でも動作が変わらないようにするため）。
#
# ここを使って Devise のメール送信者、warden フックなどを設定します。
# 多くの設定オプションはモデルで直接設定可能です。
Devise.setup do |config|
  config.warden do |manager|
    manager.default_strategies(scope: :user).unshift :two_factor_authenticatable
  end

  # Devise が使用する秘密キーです。Devise はこのキーを使って
  # ランダムなトークンを生成します。このキーを変更すると、
  # データベース内の既存の確認トークン、パスワードリセットトークン、
  # ロック解除トークンは無効になります。
  # Devise はデフォルトで `secret_key_base` を `secret_key` として使用します。
  # 以下で変更して独自の秘密キーを使用することもできます。
  # config.secret_key = 'df4099c2284fc30b20bae03accc6ca59a0f57f957ec3f2a19e2f7a6512ac0d56bc4dbb815cee1f465c0359cb0533ab8c1c8a9c4617f0bb69e495cee5f7039814'

  # ==> コントローラ設定
  # devise コントローラの親クラスを設定します。
  # config.parent_controller = 'DeviseController'

  # ==> メーラー設定
  # Devise::Mailer に表示される送信元メールアドレスを設定します。
  # 独自のメーラークラスで default "from" を指定している場合は上書きされます。
  config.mailer_sender = Rails.application.credentials.dig(:mail, :from)

  # メール送信を担当するクラスを設定します。
  # config.mailer = 'Devise::Mailer'

  # メール送信用の親クラスを設定します。
  # config.parent_mailer = 'ActionMailer::Base'

  # ==> ORM 設定(Rubyのオブジェクト（User など）と、SQLデータベース（usersテーブル）をつなぐ技術。)
  # ORM を読み込み設定します。デフォルトでは :active_record をサポートし、
  # :mongoid (bson_ext 推奨) も利用可能です。他の ORM は追加 gem により提供される場合があります。
  require "devise/orm/active_record"

  # ==> 認証機構の一般設定
  # ユーザーを認証する際に使用するキーを設定します。デフォルトは :email です。
  # 例えば [:username, :subdomain] のように設定すると、認証時に両方のパラメータが必要になります。
  # これらのパラメータは認証時にのみ使用され、セッションから取得する際には使われません。
  # 権限が必要な場合は before フィルタで実装してください。
  # 値としてハッシュを渡すと、値が存在しない場合に認証を中止するかどうかをブール値で指定できます。
  # config.authentication_keys = [:email]

  # 認証に使用するリクエストオブジェクトからのパラメータを設定します。
  # 各エントリはリクエストメソッドで、find_for_authentication メソッドに自動的に渡され、
  # モデルの検索に考慮されます。例えば :request_keys に [:subdomain] を設定すると、
  # 認証時に :subdomain が使用されます。
  # authentication_keys に関して述べた考慮事項は request_keys にも適用されます。
  # config.request_keys = []

  # 認証キーのうち小文字に変換するものを設定します。
  # これらのキーはユーザー作成・変更時および認証・検索時にダウンケースされます。デフォルトは :email です。
  config.case_insensitive_keys = [ :email ]

  # 認証キーのうち前後の空白を削除するものを設定します。
  # これらのキーはユーザー作成・変更時および認証・検索時に前後の空白が削除されます。デフォルトは :email です。
  config.strip_whitespace_keys = [ :email ]

  # リクエスト.params を通した認証を有効にするかどうかを指定します。デフォルトは true です。
  # 配列に設定すると、その戦略に対してのみ params 認証を有効にできます。
  # 例えば `config.params_authenticatable = [:database]` は database (email + password) 認証のみを有効にします。
  # config.params_authenticatable = true

  # HTTP 認証を有効にするかどうかを指定します。デフォルトは false です。
  # 配列に設定すると、その戦略に対してのみ HTTP 認証を有効にできます。
  # API 専用アプリケーションでは、標準で認証をサポートするために :database を有効にしたい場合があります。
  # サポートされている戦略は次の通りです：
  # :database      = 認証キー + パスワードによる基本認証をサポート
  # config.http_authenticatable = false

  # AJAX リクエストに対して 401 ステータスコードを返すべきか。デフォルトは true です。
  # config.http_authenticatable_on_xhr = true

  # Http Basic 認証で使用する realm。デフォルトは 'Application' です。
  # config.http_authentication_realm = 'Application'

  # 確認やパスワード回復などのワークフローを、入力されたメールアドレスが正しいか間違っているかに
  # かかわらず同じ挙動にするかどうかを切り替えます。registerable には影響しません。
  # config.paranoid = true

  # デフォルトでは Devise はユーザーをセッションに保存します。
  # 特定の戦略でストレージをスキップするにはこのオプションを設定します。
  # すべての認証経路でストレージをスキップする場合は、devise_for に skip: :sessions を渡して
  # Devise のセッションコントローラのルーティングを生成しないようにすることを検討してください。
  config.skip_session_storage = [ :http_auth ]

  # デフォルトで Devise は CSRF トークンを認証時にクリーンアップして、
  # CSRF トークン固定攻撃を避けます。これにより、サインインやサインアップを AJAX で行う場合、
  # 新しい CSRF トークンをサーバから取得する必要があります。このオプションは自己責任で無効にできます。
  # config.clean_up_csrf_token_on_authentication = true

  # false にすると Devise は eager load 時にルートをリロードしようとしなくなります。
  # アプリのブート時間を短くできますが、アプリケーションが Devise マッピングを
  # ブート時に読み込む必要がある場合はアプリが正しくブートしなくなります。
  # config.reload_routes = true

  # ==> :database_authenticatable の設定
  # bcrypt の場合、パスワードハッシュのコストでデフォルトは 12 です。
  # 他のアルゴリズムを使用する場合はハッシュを何回行うかを設定します。
  # ハッシュに使われる stretches の数はハッシュされたパスワードに保存されます。
  # これにより stretches を変更しても既存のパスワードが無効になりません。
  #
  # テスト時に stretches を 1 にすることでテストスイートのパフォーマンスを大幅に向上できます。
  # ただし、テスト以外の環境で 10 未満の値を使用することは強く推奨されません。
  # bcrypt（デフォルト）の場合、cost は stretches に対して指数的に増加します（例：20 は非常に遅い）。
  config.stretches = Rails.env.test? ? 1 : 12

  # ハッシュ化の際に使う pepper を設定します。
  # config.pepper = 'ceb5a538ae0a8f5a01f45aa086880a246a79207baae53eb30838cabecbff8a4bcb1d9ebeb1d36c6c7d0a66682a438eefcd306f3cd27b675ad729f48676af433b'

  # メールアドレスが変更されたときに元のメールアドレスへ通知を送るかどうか。
  # config.send_email_changed_notification = false

  # パスワードが変更されたときに通知メールを送るかどうか。
  config.send_password_change_notification = true

  # ==> :invitable の設定
  # 生成された招待トークンが有効な期間。
  # この期間を過ぎると招待されたリソースは招待を受け入れられなくなります。
  # invite_for が 0 のとき（デフォルト）は招待は期限切れになりません。
  config.invite_for = 12.hours

  # ユーザーが送信できる招待の数。
  # - invitation_limit が nil の場合、招待制限はなく無制限に招待できます（invitation_limit カラムは使用されません）。
  # - invitation_limit が 0 の場合、デフォルトでユーザーは招待を送信できません。
  # - invitation_limit が n > 0 の場合、ユーザーは n 件の招待を送信できます。
  # グローバル invitation_limit = 0 の場合でも、一部ユーザー用に invitation_limit カラムを変更して
  # より多く／少なく招待できるようにできます。
  # デフォルト: nil
  # config.invitation_limit = 5

  # 招待を送る際に既存ユーザーをチェックするためのキーと、validate_on_invite が設定されていない場合に使用する正規表現。
  # config.invite_key = { email: /\A[^@]+@[^@]+\z/ }
  # config.invite_key = { email: /\A[^@]+@[^@]+\z/, username: nil }

  # 招待されるレコードが有効かどうかを検証します。
  # このチェックが失敗すると招待は送信されません。
  # デフォルト: false
  # config.validate_on_invite = true

  # 招待済みステータスのユーザーに再度招待を送ると招待を再送するかどうか
  # デフォルト: true
  # config.resend_invitation = false

  # 招待者モデルのクラス名。nil の場合、#invited_by アソシエーションは多態になります。
  # デフォルト: nil
  # config.invited_by_class_name = 'User'

  # 招待者モデルへの外部キー（invited_by_class_name が設定されている場合）
  # デフォルト: :invited_by_id
  # config.invited_by_foreign_key = :invited_by_id

  # カウンタキャッシュ用のカラム名。nil の場合、#invited_by アソシエーションは counter_cache なしで宣言されます。
  # デフォルト: nil
  # config.invited_by_counter_cache = :invitations_count

  # 招待を受け入れた後に自動ログインするかどうか。false の場合、ユーザーは手動でログインする必要があります。
  # デフォルト: true
  # config.allow_insecure_sign_in_after_accept = false

  # ==> :confirmable の設定
  # 確認なしでユーザーがサイトにアクセスできる許容期間。
  # 例：2.days に設定すると、ユーザーは確認なしで2日間アクセスでき、3日目にはブロックされます。
  # nil に設定すると確認なしでのアクセスが許可されます。
  # デフォルトは 0.days（確認なしではアクセス不可）。
  # config.allow_unconfirmed_access_for = 2.days

  # トークンが無効になる前にユーザーがアカウントを確認できる期間。
  # 例：3.days に設定すると、メール送信後3日以内であれば確認可能で、4日目以降はトークンでの確認は不可。
  # デフォルトは nil（確認に期限なし）。
  # config.confirm_within = 3.days

  # true の場合、メールアドレスの変更時にその変更を適用するためにも確認を要求します（初回確認と同様）。
  # 追加の unconfirmed_email DB フィールドが必要です（マイグレーション参照）。
  # 確認されるまで新しいメールは unconfirmed_email に保存され、確認成功時に email にコピーされます。
  config.reconfirmable = true

  # アカウント確認に使用するキーを定義します
  # config.confirmation_keys = [:email]

  # ==> :rememberable の設定
  # ユーザーが再ログインなしで記憶される期間。
  # config.remember_for = 12.hours

  # サインアウト時にすべての remember me トークンを無効にするかどうか。
  config.expire_all_remember_me_on_sign_out = true

  # true の場合、クッキーで記憶されている場合にユーザーの remember 期間を延長します。
  # config.extend_remember_period = false

  # 作成されるクッキーに渡すオプション。例えば secure: true を設定して SSL のみのクッキーにできます。
  # config.rememberable_options = {}

  # ==> :validatable の設定
  # パスワード長の範囲。
  config.password_length = 6..128

  # メール形式を検証するための正規表現。@ がちょうど1つ存在することをアサートします。
  # これは主にユーザーへのフィードバック用であり、メールの実際の有効性を保証するものではありません。
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> :timeoutable の設定
  # アクティビティなしでユーザーセッションをタイムアウトさせる時間。これを過ぎると再認証が必要になります。
  # デフォルトは 30 分です。
  # config.timeout_in = 30.minutes

  # ==> :lockable の設定
  # アカウントをロックする戦略を定義します。
  # :failed_attempts = サインイン失敗回数によりアカウントをロックします。
  # :none            = ロック戦略なし。自身でロックを扱う必要があります。
  config.lock_strategy = :failed_attempts

  # ロックおよびアンロック時に使用するキーを定義します
  config.unlock_keys = [ :email ]

  # アカウントをアンロックするための戦略を定義します。
  # :email = ユーザーにアンロックリンクをメールで送信
  # :time  = 指定時間後にログインを再有効化（unlock_in を参照）
  # :both  = 両方の戦略を有効にする
  # :none  = アンロック戦略なし。自身で扱う必要があります。
  config.unlock_strategy = :email

  # lock_strategy が failed_attempts の場合にアカウントをロックするまでの認証試行回数。
  config.maximum_attempts = 5

  # :time がアンロック戦略に含まれる場合にアカウントをアンロックするまでの時間間隔。
  # config.unlock_in = 1.hour

  # アカウントがロックされる直前の最後の試行で警告するかどうか。
  config.last_attempt_warning = true

  # ==> :recoverable の設定
  #
  # パスワード回復時に使用するキーを定義します
  config.reset_password_keys = [ :email ]

  # リセットパスワードキーでパスワードをリセットできる時間間隔。
  # ユーザーがパスワードを変更する時間が短すぎないように注意してください。
  config.reset_password_within = 6.hours

  # false に設定すると、パスワードリセット後にユーザーを自動でサインインしません。
  # デフォルトは true で、リセット後に自動でサインインされます。
  config.sign_in_after_reset_password = false

  # ==> :encryptable の設定
  # bcrypt（デフォルト）以外のハッシュや暗号化アルゴリズムを使えるようにします。
  # :sha1, :sha512 や他の認証ツール由来のアルゴリズムを使うことができます。
  #
  # bcrypt 以外を使う場合は `devise-encryptable` gem が必要です。
  # config.encryptor = :sha512

  # ==> スコープ設定
  # スコープ化されたビューをオンにします。"sessions/new" をレンダリングする前に
  # "users/sessions/new" を先に探します。デフォルトはオフ（デフォルトビューのみを使う場合は速い）。
  # config.scoped_views = false

  # Warden に渡されるデフォルトスコープを設定します。デフォルトはルートで最初に宣言された devise ロール（通常 :user）。
  # config.default_scope = :user

  # false に設定すると /users/sign_out は現在のスコープのみをサインアウトします。
  # デフォルトでは Devise はすべてのスコープからサインアウトします。
  # config.sign_out_all_scopes = true

  # ==> ナビゲーション設定
  # ナビゲーションとして扱うフォーマットのリスト。:html のようなフォーマットは
  # ユーザーがアクセス権を持たない場合サインインページへリダイレクトしますが、
  # :xml や :json のようなフォーマットは 401 を返すべきです。
  #
  # :iphone や :mobile のような追加のナビゲーションフォーマットがある場合はリストに追加してください。
  #
  # 下の "*/*" は Internet Explorer のリクエストにマッチさせるために必要です。
  # config.navigational_formats = ['*/*', :html, :turbo_stream]

  # サインアウトに使用するデフォルトの HTTP メソッド。デフォルトは :delete です。
  config.sign_out_via = :delete

  # ==> OmniAuth
  # 新しい OmniAuth プロバイダを追加します。モデルやフックのセットアップについては wiki を参照してください。
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'
  config.omniauth :google_oauth2,
  Rails.application.credentials.dig(:google, :client_id),
  Rails.application.credentials.dig(:google, :client_secret),
  scope: "email,profile",
  prompt: "select_account",
  redirect_uri: ENV["REDIRECT_HOST"] + "/users/auth/google_oauth2/callback"
  # ==> Warden 設定
  # サポートされていない戦略を使いたい場合や failure app を変更したい場合は
  # config.warden ブロック内で設定できます。
  #

  # ==> マウント可能エンジンの設定
  # Devise をエンジン内で使用する場合（例：MyEngine）でそのエンジンがマウント可能な場合、
  # 考慮すべき追加設定があります。以下はエンジンが次のようにマウントされていると仮定します：
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # `devise_for` を呼んだルータは次のようになります：
  # config.router_name = :my_engine
  #
  # OmniAuth を使用する場合、Devise は自動的に OmniAuth パスを設定できないため手動で設定する必要があります。
  # users スコープでは次のようになります：
  # config.omniauth_path_prefix = '/my_engine/users/auth'

  # ==> Hotwire/Turbo 設定
  # Hotwire/Turbo と Devise を使う場合、エラー応答や一部リダイレクトの HTTP ステータスは以下に合わせる必要があります。
  # 既存アプリ向けのデフォルトは `200 OK` と `302 Found` ですが、新しいアプリはこれらの新しいデフォルトが
  # Hotwire/Turbo の挙動に合うように生成されます。
  # 補足：将来の Devise のバージョンでこれらが新しいデフォルトになる可能性があります。
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # ==> :registerable の設定
  # pwned_password 拡張機能の設定
  config.min_password_matches = 10
  # false に設定すると、パスワード変更後にユーザーを自動でサインインしません。
  # デフォルトは true で、パスワード変更後に自動サインインされます。
  # config.sign_in_after_change_password = true

  config.otp_allowed_drift = 60 if Rails.env.test?
end
