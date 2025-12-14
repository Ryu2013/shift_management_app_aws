require "rails_helper"

RSpec.describe "UserClients", type: :request do
  let(:password) { "password123" }
  let!(:admin) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { admin.office }
  let!(:team)   { admin.team }
  let!(:client) { create(:client, office: office, team: team) }
  let!(:another_user) { create(:user, office: office, team: team, password: password, password_confirmation: password) }

  def sign_in_admin
    post user_session_path, params: { user: { email: admin.email, password: password } }
  end

  describe "GET /teams/:team_id/clients/:client_id/user_clients/new" do
    it "新規作成画面を表示できる" do
      sign_in_admin

      get new_team_client_user_client_path(team, client)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /teams/:team_id/clients/:client_id/user_clients" do
    it "作成に成功し、作成画面にリダイレクトする" do
      sign_in_admin

      expect do
        post team_client_user_clients_path(team, client), params: {
          user_client: {
            office_id: office.id,
            user_id: another_user.id,
            client_id: client.id,
            note: "メモ"
          }
        }
      end.to change(UserClient, :count).by(1)

      expect(response).to redirect_to(new_team_client_user_client_path(team, client))
    end

    it "バリデーションエラーの場合は422で再描画する" do
      sign_in_admin

      expect do
        post team_client_user_clients_path(team, client), params: {
          user_client: {
            office_id: office.id,
            client_id: client.id,
            note: "ユーザー未指定"
          }
        }
      end.not_to change(UserClient, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /teams/:team_id/clients/:client_id/user_clients/:id" do
    it "削除して一覧にリダイレクトする" do
      sign_in_admin
      user_client = create(:user_client, office: office, client: client, user: another_user)

      expect do
        delete team_client_user_client_path(team, client, user_client)
      end.to change(UserClient, :count).by(-1)

      expect(response).to redirect_to(team_client_user_clients_path(team, client))
      expect(response).to have_http_status(:see_other)
    end
  end
end
