# spec/requests/users/two_factor_spec.rb

require 'rails_helper'

RSpec.describe "Users::TwoFactor", type: :request do
  let(:office) { create(:office) }
  # setupアクション内で @office.teams を呼んでいるため、officeに関連するユーザーを作成
  let(:user) { create(:user, office: office) }

  # adminの場合のテストデータ用
  let(:admin_user) { create(:user, :admin, office: office) }
  let!(:team) { create(:team, office: office) }
  let!(:client) { create(:client, team: team) }

  before do
    # Deviseのログインヘルパー
    sign_in user

    allow_any_instance_of(ApplicationController).to receive(:office_authenticate) do |controller|
      controller.instance_variable_set(:@office, office)
    end
  end

  describe "GET /users/two_factor/setup (または new)" do
    context "ログインしていない場合" do
      before { sign_out user }
      it "ログイン画面にリダイレクトされる" do
        get users_two_factor_setup_path # ルーティングに合わせて変更してください
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      it "正常にレスポンスが返り、QRコードとシークレットが生成される" do
        get users_two_factor_setup_path

        expect(response).to have_http_status(:ok)

        # セッションに一時的なシークレットが保存されているか確認
        expect(session[:pending_otp_secret]).to be_present
        # インスタンス変数がセットされているか確認（request specでも assigns が使える設定の場合）
        # expect(assigns(:qr_svg)).to be_present
        # もし assigns が使えない場合は body をチェック
        expect(response.body).to include("<svg")
      end
    end

    context "管理者の場合" do
      before { sign_in admin_user }

      it "@team と @client がセットされる" do
        get users_two_factor_setup_path
        # ビューにチーム名などが表示されているかで間接的にテストするか、
        # assignsが使える環境なら変数の中身をチェック
        expect(response.body).to include("<a class=\"back-image-link\"")
      end
    end
  end

  describe "POST /users/two_factor/confirm" do
    let(:otp_secret) { User.generate_otp_secret }

    # テスト前にセッションにシークレットを仕込んでおく（setupアクションを通った状態を模倣）
    before do
      # Request Specで直接セッションを操作するのは難しいため、
      # gem 'rack_session_access' を使うか、
      # 一度 setup アクションを叩いてセッションを作るのが確実です。
      get users_two_factor_setup_path

      # 生成されたシークレットを取得（またはモックで固定する手もあります）
      # ここではシンプルに、validate_and_consume_otp! をモックして制御します
    end

    context "正しいワンタイムパスワードが入力された場合" do
      before do
        # validate_and_consume_otp! が true を返すようにモック化
        allow_any_instance_of(User).to receive(:validate_and_consume_otp!).and_return(true)
      end

      it "2要素認証が有効化され、ルートパスへリダイレクトされる" do
        post users_confirm_two_factor_path, params: { otp_attempt: '123456' }

        user.reload
        # DBが更新されていること
        expect(user.otp_required_for_login).to be true
        expect(user.otp_secret).to be_present

        # リダイレクト確認
        expect(response).to redirect_to(root_path)

        # セッションのキーが削除されている確認（次のリクエストでnilになる等）
        # Request Specではセッションの削除確認は難しいので省略可
      end
    end

    context "誤ったワンタイムパスワードが入力された場合" do
      before do
        # validate_and_consume_otp! が false を返すようにモック化
        allow_any_instance_of(User).to receive(:validate_and_consume_otp!).and_return(false)
      end

      it "DBは更新されず、422エラーでセットアップ画面が再描画される" do
        post users_confirm_two_factor_path, params: { otp_attempt: '000000' }

        user.reload
        expect(user.otp_required_for_login).to be_falsey

        expect(response).to have_http_status(:unprocessable_entity)

        # フラッシュメッセージの確認
        expect(flash[:alert]).to eq I18n.t("users.two_factor.invalid_code")

        # 再描画時にもQRコードが生成されていること（ensure_secret_key!が走っているか）
        expect(response.body).to include("<svg")
      end
    end
  end
end
