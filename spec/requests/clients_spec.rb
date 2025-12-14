require "rails_helper"

RSpec.describe "Clients", type: :request do
  let(:password) { "password123" }
  let!(:admin) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { admin.office }
  let!(:team_a) { admin.team }
  let!(:team_b) { create(:team, office: office) }
  let!(:client_a) { create(:client, office: office, team: team_a) }
  let!(:client_b) { create(:client, office: office, team: team_b) }

  def sign_in_admin
    post user_session_path, params: { user: { email: admin.email, password: password } }
  end

  describe "GET /teams/:team_id/clients" do
    context "selected_team_id が指定された場合" do
      it "指定されたチームのクライアント一覧にリダイレクトする" do
        sign_in_admin

        get team_clients_path(team_a), params: { selected_team_id: team_b.id }

        expect(response).to redirect_to(team_clients_path(team_b))
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET /teams/:team_id/clients/:id/edit" do
    it "編集画面を表示できる" do
      sign_in_admin

      get edit_team_client_path(team_a, client_a)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /teams/:team_id/clients" do
    let(:valid_params) do
      {
        client: {
          name: "新規クライアント",
          address: "東京都",
          team_id: team_a.id
        }
      }
    end

    it "作成に成功し、一覧へリダイレクトする" do
      sign_in_admin

      expect do
        post team_clients_path(team_a), params: valid_params
      end.to change(Client, :count).by(1)

      expect(response).to redirect_to(team_clients_path(team_a))
      expect(response).to have_http_status(:found)
    end

    it "バリデーションエラーの場合は422で再描画する" do
      sign_in_admin

      expect do
        post team_clients_path(team_a), params: { client: valid_params[:client].merge(name: "") }
      end.not_to change(Client, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /teams/:team_id/clients/:id" do
    it "更新に成功し、一覧へリダイレクトする" do
      sign_in_admin

      patch team_client_path(team_a, client_a), params: { client: { name: "変更後の名前" } }

      expect(response).to redirect_to(team_clients_path(team_a))
      expect(response).to have_http_status(:see_other)
      expect(client_a.reload.name).to eq("変更後の名前")
    end

    it "バリデーションエラーの場合は422で再描画する" do
      sign_in_admin
      original_name = client_a.name

      patch team_client_path(team_a, client_a), params: { client: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(client_a.reload.name).to eq(original_name)
    end
  end

  describe "DELETE /teams/:team_id/clients/:id" do
    it "削除して一覧へリダイレクトする" do
      sign_in_admin
      deletable = create(:client, office: office, team: team_b)

      expect do
        delete team_client_path(team_b, deletable)
      end.to change(Client, :count).by(-1)

      expect(response).to redirect_to(team_clients_path(team_b))
      expect(response).to have_http_status(:see_other)
    end
  end
end
