require "rails_helper"

RSpec.describe "Shifts", type: :request do
  let(:password) { "password123" }
  let!(:user) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { user.office }
  let!(:team) { user.team }
  let!(:client) { create(:client, office: office, team: team) }

  def sign_in_user
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  before { sign_in_user }

  describe "GET /teams/:team_id/clients/:client_id/shifts/new" do
    it "正常にレンダリングされること" do
      get new_team_client_shift_path(team, client, date: Date.current.strftime("%Y-%m"))

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /teams/:team_id/clients/:client_id/shifts/:id/edit" do
    let!(:shift) { create(:shift, office: office, client: client) }

    it "正常にレンダリングされること" do
      get edit_team_client_shift_path(team, client, shift)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /teams/:team_id/clients/:client_id/shifts" do
    let(:valid_params) do
      {
        shift: {
          client_id: client.id,
          date: Date.current,
          start_time: "09:00",
          end_time: "11:00",
          shift_type: "day",
          work_status: "work"
        }
      }
    end

    context "サブスク有効" do
      before { office.update!(subscription_status: "active") }

      it "シフトを作成し、一覧ページへリダイレクトすること" do
        expect do
          post team_client_shifts_path(team, client), params: valid_params
        end.to change(Shift, :count).by(1)

        expect(response).to redirect_to(team_client_shifts_path(team, client))
        expect(response).to have_http_status(:found)
      end

      it "無効なパラメータの場合、エラーと共に新規作成ページを再描画すること" do
        expect do
          post team_client_shifts_path(team, client), params: { shift: valid_params[:shift].merge(start_time: nil) }
        end.not_to change(Shift, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "サブスク無効" do
      before { office.update!(subscription_status: "canceled") }
      it "作成せずサブスクページへリダイレクトすること" do
        create_list(:user, 4, office: office)
        expect do
          post team_client_shifts_path(team, client), params: valid_params
        end.not_to change(Shift, :count)

        expect(response).to redirect_to(subscriptions_index_path)
        expect(flash[:alert]).to eq("サブスクリプションが有効ではないため、メッセージを送信できません。")
      end
    end
  end

  describe "POST /teams/:team_id/clients/:client_id/shifts/generate_monthly_shifts" do
    let(:month) { Date.new(2025, 2, 1) }
    let(:date_param) { month.strftime("%Y-%m") }
    let!(:client_need) do
      create(:client_need,
             office: office,
             client: client,
             week: :monday,
             shift_type: :day,
             start_time: "09:00",
             end_time: "11:00",
             slots: 2)
    end
    let(:expected_created) do
      (month.beginning_of_month..month.end_of_month).count { |d| d.wday == ClientNeed.weeks[client_need.week] } * client_need.slots
    end

    it "必要数に基づいて月間シフトを作成し、リダイレクトすること" do
      expect do
        post generate_monthly_shifts_team_client_shifts_path(team, client), params: { date: date_param }
      end.to change(Shift, :count).by(expected_created)

      expect(response).to redirect_to(team_client_shifts_path(team, client, date: date_param))
      expect(flash[:notice]).to eq("シフトを#{expected_created}件作成しました。")
    end
  end

  describe "PATCH /teams/:team_id/clients/:client_id/shifts/:id" do
    let!(:shift) do
      create(:shift, office: office, client: client, start_time: "09:00", end_time: "11:00", shift_type: :day, work_status: :not_work)
    end

    let(:update_params) do
      {
        shift: {
          client_id: client.id,
          date: shift.date,
          start_time: "10:00",
          end_time: "12:00",
          shift_type: "night",
          work_status: "work"
        }
      }
    end

    it "シフトを更新し、一覧ページへリダイレクトすること" do
      patch team_client_shift_path(team, client, shift), params: update_params

      expect(response).to redirect_to(team_client_shifts_path(team, client))
      expect(response).to have_http_status(:see_other)
      shift.reload
      expect(shift.start_time.strftime("%H:%M")).to eq("10:00")
      expect(shift.end_time.strftime("%H:%M")).to eq("12:00")
      expect(shift.shift_type).to eq("night")
      expect(shift.work_status).to eq("work")
    end

    it "無効なパラメータの場合、エラーと共に編集ページを再描画すること" do
      patch team_client_shift_path(team, client, shift), params: { shift: update_params[:shift].merge(start_time: nil) }

      expect(response).to have_http_status(:unprocessable_entity)
      shift.reload
      expect(shift.start_time.strftime("%H:%M")).to eq("09:00")
      expect(shift.end_time.strftime("%H:%M")).to eq("11:00")
      expect(shift.shift_type).to eq("day")
      expect(shift.work_status).to eq("not_work")
    end
  end

  describe "PATCH /employee/shifts/:id" do
    let(:user) { create(:user, role: :employee, password: password, password_confirmation: password) }
    let!(:shift) { create(:shift, office: office, client: client, user: user, work_status: :not_work) }

    it "ログイン中の従業員のシフトのwork_statusを更新し、従業員シフト一覧へリダイレクトすること" do
      patch employee_shift_path(shift), params: { shift: { work_status: "work" } }

      expect(response).to redirect_to(employee_shifts_path)
      expect(flash[:notice]).to eq("シフトを更新しました。")
      expect(shift.reload.work_status).to eq("work")
    end

    it "更新に失敗した場合、エラーと共に一覧ページを再描画すること" do
      allow_any_instance_of(Shift).to receive(:update).and_return(false)

      patch employee_shift_path(shift), params: { shift: { work_status: "work" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("シフトの更新に失敗しました。")
      expect(shift.reload.work_status).to eq("not_work")
    end
  end

  describe "GET /teams/:team_id/clients/:client_id/shifts" do
    let(:date_param) { Date.current.strftime("%Y-%m") }
    let!(:other_team) { create(:team, office: office) }
    let!(:other_team_client) { create(:client, office: office, team: other_team) }
    let!(:another_client_in_same_team) { create(:client, office: office, team: team) }

    it "selected_team_idが異なる場合、選択されたチームへリダイレクトすること" do
      get team_client_shifts_path(team, client), params: { selected_team_id: other_team.id, date: date_param }

      expect(response).to redirect_to(team_client_shifts_path(other_team, client, date: date_param))
    end

    it "selected_client_idが異なる場合、選択されたクライアントへリダイレクトすること" do
      get team_client_shifts_path(team, client), params: { selected_client_id: another_client_in_same_team.id, date: date_param }

      expect(response).to redirect_to(team_client_shifts_path(team, another_client_in_same_team, date: date_param))
    end
  end

  describe "DELETE /teams/:team_id/clients/:client_id/shifts/:id" do
    let!(:shift) { create(:shift, office: office, client: client) }

    it "シフトを削除し、リダイレクトすること" do
      expect do
        delete team_client_shift_path(team, client, shift)
      end.to change(Shift, :count).by(-1)

      expect(response).to redirect_to(team_client_shifts_path(team, client))
      expect(response).to have_http_status(:see_other)
    end
  end
end
