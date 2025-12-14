require 'rails_helper'

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  describe "GET /users/auth/google_oauth2/callback" do
    before do
      # 1. OmniAuthをテストモードにする
      OmniAuth.config.test_mode = true

      # 2. Deviseのマッピングを設定（Deviseのコントローラーを直接叩く場合に必要）
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    end

    after do
      # テスト後は設定をリセットしておく
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    context "Google認証が成功した場合" do
      before do
        # 3. Googleから返ってくる「成功データ」を偽装（モック）する
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'test@example.com',
            name: 'Test User'
          },
          credentials: {
            token: 'mock_token',
            refresh_token: 'mock_refresh_token'
          }
        })
      end

      it "ログインしてルートパス（または指定のパス）へリダイレクトする" do
        # リクエストを実行
        get user_google_oauth2_omniauth_callback_path
        team = Team.last  # ユーザー作成時に関連付けられたチームを取得

        # 期待する挙動
        expect(response).to redirect_to(new_team_client_path(team)) # ログイン後のパスに合わせて変更してください
        expect(flash[:notice]).to include("Googleアカウントでログインしました。")

        # 実際にユーザーが作成/ログインされているか確認
        expect(User.find_by(email: 'test@example.com')).to be_present
      end
    end

    context "Google認証データは正しいが、ユーザー保存に失敗した場合" do
      before do
        # 成功データをセット
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: { email: 'test@example.com' }
        })

        # User.from_omniauth が保存されていないユーザーを返すように強制する（モック）
        # ※ モデルの実装に依存せず、コントローラーの else 分岐をテストするため
        unsaved_user = User.new
        allow(User).to receive(:from_omniauth).and_return(unsaved_user)
      end

      it "新規登録画面へリダイレクトする" do
        get user_google_oauth2_omniauth_callback_path

        expect(response).to redirect_to(new_user_registration_url)
        # セッションにデータが入っているか確認しても良い
        expect(session["devise.google_data"]).to be_present
      end
    end

    context "Google認証自体が失敗/キャンセルされた場合" do
      before do
        # 失敗データを偽装
        OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      end

      it "ルートパスへリダイレクトし、アラートを表示する" do
        # Deviseのfailureパスへリクエスト（通常はこのパスになります）
        # ※ ルーティング設定によってはパスが異なる場合があります
        get "/users/auth/google_oauth2/callback"

        expect(response).to redirect_to(root_path)
        # コントローラーの failure アクションでセットしているメッセージ
        expect(flash[:alert]).to include("Google認証に失敗しました。")
      end
    end
  end
end
