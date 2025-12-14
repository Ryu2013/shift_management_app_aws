require "rails_helper"

RSpec.describe "Registrations", type: :request do
  let(:password) { "password123" }

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          name: "New User",
          address: "Tokyo",
          email: "new_user@example.com",
          password: password,
          password_confirmation: password
        }
      }
    end

    it "事業所/チームと管理者権限を持つユーザーを作成し、クエリパラメータを保持してリダイレクトすること" do
      expect do
        post user_registration_path(ref: "ref-code"), params: valid_params
      end.to change(User, :count).by(1)
        .and change(Office, :count).by(1)
        .and change(Team, :count).by(1)

      user = User.order(:id).last
      expect(user.role).to eq("admin")
      expect(user.office).to be_present
      expect(user.team).to be_present
      expect(user).not_to be_confirmed

      expect(response).to redirect_to(new_user_registration_path(ref: "ref-code"))
    end

    it "バリデーション失敗時に作成をロールバックすること" do
      expect do
        post user_registration_path, params: {
          user: {
            name: "",
            email: "invalid@example.com",
            password: password,
            password_confirmation: "mismatch"
          }
        }
      end.to change(User, :count).by(0)
        .and change(Office, :count).by(0)
        .and change(Team, :count).by(0)

      expect([ 200, 422 ]).to include(response.status)
    end
  end

  describe "GET /users/edit" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "事業所セッションがない場合にリダイレクトすること" do
      get edit_user_registration_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("事業所情報が不明です")
    end
  end

  describe "PATCH /users" do
    let(:user) { create(:user) }
    let!(:other_team) { create(:team, office: user.office) }

    def sign_in_via_form
      post user_session_path, params: { user: { email: user.email, password: password } }
    end

    context "認証情報の変更なしでプロフィールフィールドを更新する場合" do
      it "現在のパスワードなしで更新し、編集パスへリダイレクトすること" do
        sign_in_via_form

        patch user_registration_path, params: {
          user: {
            name: "Updated Name",
            address: "New Address",
            team_id: other_team.id
          }
        }

        expect(response).to redirect_to(edit_user_registration_path(user))
        user.reload
        expect(user.name).to eq("Updated Name")
        expect(user.address).to eq("New Address")
        expect(user.team_id).to eq(other_team.id)
      end
    end

    context "メールアドレスを変更する場合" do
      it "現在のパスワードが必要であり、それなしでは更新されないこと" do
        sign_in_via_form

        patch user_registration_path, params: {
          user: {
            email: "new_email@example.com"
          }
        }

        expect([ 200, 422 ]).to include(response.status)
        expect(user.reload.email).not_to eq("new_email@example.com")
      end
    end
  end
end
