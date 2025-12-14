require "rails_helper"

RSpec.describe "ClientNeeds", type: :request do
  let(:password) { "password123" }
  let!(:user) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:client) { create(:client, office: user.office, team: user.team) }

  def sign_in_user
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  describe "GET /teams/:team_id/clients/:client_id/client_needs" do
    it "一覧を表示できる" do
      create(:client_need, client: client, office: user.office, week: :monday)
      create(:client_need, client: client, office: user.office, week: :tuesday)

      sign_in_user
      get team_client_client_needs_path(client.team, client)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /teams/:team_id/clients/:client_id/client_needs/new" do
    it "新規作成フォームを表示できる" do
      sign_in_user

      get new_team_client_client_need_path(client.team, client)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /teams/:team_id/clients/:client_id/client_needs" do
    let(:valid_params) do
      {
        client_need: {
          week: :monday,
          shift_type: :day,
          start_time: "09:00",
          end_time: "17:00",
          slots: 2
        }
      }
    end

    it "作成に成功し、クライアント編集にリダイレクトする" do
      sign_in_user

      expect do
        post team_client_client_needs_path(client.team, client), params: valid_params
      end.to change(ClientNeed, :count).by(1)

      expect(response).to redirect_to(edit_team_client_path(client.team, client))
    end

    it "不正入力の場合は422で再描画する" do
      sign_in_user

      expect do
        post team_client_client_needs_path(client.team, client), params: { client_need: { week: :monday } }
      end.not_to change(ClientNeed, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /teams/:team_id/clients/:client_id/client_needs/:id" do
    it "削除して新規作成画面にリダイレクトする" do
      sign_in_user
      client_need = create(:client_need, client: client, office: user.office)

      expect do
        delete team_client_client_need_path(client.team, client, client_need)
      end.to change(ClientNeed, :count).by(-1)

      expect(response).to redirect_to(new_team_client_client_need_path(client.team, client))
      expect(response).to have_http_status(:see_other)
    end
  end
end
