require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:password) { 'password123' }

  describe 'POST /users/sign_in' do
    context 'adminユーザーログインフロー' do
      let!(:user) { create(:user, role: :admin, confirmed_at: Time.current, password: password, password_confirmation: password, otp_required_for_login: false) }

      it 'サインイン成功し、適切なリダイレクトが行われること' do
        post user_session_path, params: { user: { email: user.email, password: password } }

        expect(response).to redirect_to(new_team_client_path(user.team))
      end
    end

    context '2FA有効ユーザー（1画面）' do
      let!(:user) { create(:user, role: :admin, confirmed_at: Time.current, password: password, password_confirmation: password, otp_required_for_login: true) }

      it 'メール+パスワード+OTPでサインイン成功し、適切にリダイレクトされること' do
        user.update!(otp_secret: User.generate_otp_secret)
        otp = user.current_otp

        post user_session_path, params: { user: { email: user.email, password: password, otp_attempt: otp } }

        expect(response).to redirect_to(new_team_client_path(user.team))
      end
    end

    context 'employeeユーザーログインフロー' do
      let!(:user) { create(:user, role: :employee, confirmed_at: Time.current, password: password, password_confirmation: password, otp_required_for_login: false) }

      it '2FA無効のemployeeはサインイン成功し、employee_shifts_pathへリダイレクトすること' do
        post user_session_path, params: { user: { email: user.email, password: password } }

        expect(response).to redirect_to(employee_shifts_path)
      end
    end

    context '2FA有効ユーザー（1画面・employee）' do
      let!(:user) { create(:user, role: :employee, confirmed_at: Time.current, password: password, password_confirmation: password, otp_required_for_login: true) }

      it 'メール+パスワード+OTPでサインイン成功し、employee_shifts_pathへリダイレクトすること' do
        user.update!(otp_secret: User.generate_otp_secret)
        otp = user.current_otp

        post user_session_path, params: { user: { email: user.email, password: password, otp_attempt: otp } }

        expect(response).to redirect_to(employee_shifts_path)
      end
    end

    context '無効な認証情報（パスワード不一致）' do
      let!(:user) { create(:user, confirmed_at: Time.current, password: password, password_confirmation: password) }

      it 'サインインに失敗し、後続の保護ページにアクセスできないこと' do
        post user_session_path, params: { user: { email: user.email, password: 'wrongpassword' } }

        # 成否の実装差（200 or 422）を許容
        expect([ 200, 422 ]).to include(response.status)

        # 未ログインなので保護ページにリダイレクトされる
        get employee_shifts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '未確認ユーザー（Confirmable）' do
      let!(:user) { create(:user, confirmed_at: nil, password: password, password_confirmation: password) }

      it 'サインインに失敗し、保護ページにアクセスできないこと' do
        post user_session_path, params: { user: { email: user.email, password: password } }

        # 実装により 200 再描画 or 302 でサインインに戻す可能性あり
        expect([ 200, 302, 422 ]).to include(response.status)

        get employee_shifts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'admin（クライアントが既に存在する場合の遷移）' do
      let!(:user)   { create(:user, role: :admin, confirmed_at: Time.current, password: password, password_confirmation: password) }
      let!(:client) { create(:client, office: user.office, team: user.team) }

      it 'team_client_shifts_path へリダイレクトされること' do
        post user_session_path, params: { user: { email: user.email, password: password } }
        expect(response).to redirect_to(team_client_shifts_path(user.team, client))
      end
    end

    context 'サインアウト' do
      let!(:user) { create(:user, confirmed_at: Time.current, password: password, password_confirmation: password) }

      it 'ログアウト後は保護ページにアクセスできないこと' do
        # サインイン
        post user_session_path, params: { user: { email: user.email, password: password } }

        # サインアウト
        delete destroy_user_session_path

        # 保護ページにアクセスするとログイン画面へ
        get employee_shifts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '2FA有効（1画面）でOTP不正' do
      let!(:user) { create(:user, role: :admin, confirmed_at: Time.current, password: password, password_confirmation: password, otp_required_for_login: true) }

      it 'サインインに失敗し、保護ページにアクセスできないこと' do
        user.update!(otp_secret: User.generate_otp_secret)
        wrong_code = '000000'

        post user_session_path, params: { user: { email: user.email, password: password, otp_attempt: wrong_code } }

        expect([ 200, 422 ]).to include(response.status)
        get employee_shifts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
