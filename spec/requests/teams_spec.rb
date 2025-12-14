require "rails_helper"

RSpec.describe "Teams", type: :request do
  let(:password) { "password123" }
  let!(:user) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { user.office }
  let!(:team)   { user.team }
  let!(:client) { create(:client, office: office, team: team) }

  def sign_in_user
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  describe "GET /teams" do
    it "一覧を表示できる" do
      sign_in_user

      get teams_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /teams/new" do
    it "新規作成画面を表示できる" do
      sign_in_user

      get new_team_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /teams/:id/edit" do
    it "編集画面を表示できる" do
      sign_in_user

      get edit_team_path(team)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /teams" do
    it "作成に成功し、クライアント登録画面へリダイレクトする" do
      sign_in_user

      expect do
        post teams_path, params: { team: { name: "新規チーム" } }
      end.to change(Team, :count).by(1)

      new_team = Team.order(:created_at).last
      expect(response).to redirect_to(new_team_client_path(team_id: new_team.id))
    end

    it "バリデーションエラーの場合は422で再描画する" do
      sign_in_user

      expect do
        post teams_path, params: { team: { name: "" } }
      end.not_to change(Team, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /teams/:id" do
    it "更新に成功し、一覧へリダイレクトする" do
      sign_in_user

      patch team_path(team), params: { team: { name: "変更後の名前" } }

      expect(response).to redirect_to(teams_path(team))
      expect(response).to have_http_status(:see_other)
      expect(team.reload.name).to eq("変更後の名前")
    end

    it "バリデーションエラーの場合は422で再描画する" do
      sign_in_user

      patch team_path(team), params: { team: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(team.reload.name).not_to eq("")
    end
  end

  describe "DELETE /teams/:id" do
    it "削除して一覧へリダイレクトする" do
      sign_in_user
      deletable_team = create(:team, office: office)

      expect do
        delete team_path(deletable_team)
      end.to change(Team, :count).by(-1)

      expect(response).to redirect_to(teams_path)
      expect(response).to have_http_status(:see_other)
    end
  end
end
