require "rails_helper"

RSpec.describe "Offices", type: :request do
  let(:password) { "password123" }
  let!(:user) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { user.office }
  let!(:team)   { user.team }
  let!(:client) { create(:client, office: office, team: team) }

  def sign_in_user
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  describe "GET /offices/:id/edit" do
    it "編集画面を表示できる" do
      sign_in_user

      get edit_office_path(office)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /offices/:id" do
    it "更新に成功し、シフト画面へリダイレクトする" do
      sign_in_user

      patch office_path(office), params: { office: { name: "新しいオフィス名" } }

      expect(response).to redirect_to(team_client_shifts_path(team, client))
      expect(response).to have_http_status(:see_other)
      expect(office.reload.name).to eq("新しいオフィス名")
    end

    it "バリデーションエラーの場合は422で再描画する" do
      sign_in_user

      patch office_path(office), params: { office: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("更新に失敗しました。もう一度お試しください。")
      expect(office.reload.name).not_to eq("")
    end
  end
end
