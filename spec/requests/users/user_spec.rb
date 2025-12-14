require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:password) { "password123" }
  let!(:admin) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { admin.office }
  let!(:team) { admin.team }
  let!(:other_team) { create(:team, office: office) }
  let!(:client) { create(:client, office: office, team: team) }
  let!(:other_client) { create(:client, office: office, team: other_team) }
  let!(:target_user) { create(:user, office: office, team: team, password: password, password_confirmation: password) }

  def sign_in_user
    post user_session_path, params: { user: { email: admin.email, password: password } }
  end

  describe "GET /teams/:team_id/users" do
    it "selected_team_idがある時はその部署へリダイレクトする" do
      sign_in_user

      get team_users_path(team, selected_team_id: other_team.id)

      expect(response).to redirect_to(team_users_path(other_team))
      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /teams/:team_id/users/:id/edit" do
    it "編集画面を表示できる" do
      sign_in_user

      get edit_team_user_path(team, target_user)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /teams/:team_id/users/:id" do
    it "情報を更新できる" do
      sign_in_user

      patch team_user_path(team, target_user), params: { user: { name: "変更後の名前" } }

      expect(response).to redirect_to(team_users_path(target_user.team))
      expect(response).to have_http_status(:see_other)
      expect(target_user.reload.name).to eq("変更後の名前")
    end

    it "空のpasswordとemailは更新対象に含めない" do
      sign_in_user
      original_email = target_user.email

      patch team_user_path(team, target_user), params: {
        user: {
          name: "空欄でも更新される名前",
          email: "",
          password: "",
          password_confirmation: ""
        }
      }

      expect(response).to redirect_to(team_users_path(target_user.team))
      expect(response).to have_http_status(:see_other)
      target_user.reload
      expect(target_user.email).to eq(original_email)
      expect(target_user.valid_password?(password)).to be true
      expect(target_user.name).to eq("空欄でも更新される名前")
    end
  end

  describe "DELETE /teams/:team_id/users/:id" do
    it "ユーザーを削除できる" do
      sign_in_user
      deletable_user = create(:user, office: office, team: team)

      expect do
        delete team_user_path(team, deletable_user)
      end.to change(User, :count).by(-1)

      expect(response).to redirect_to(team_users_path(admin.team))
      expect(response).to have_http_status(:see_other)
    end
  end
end
