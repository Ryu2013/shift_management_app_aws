class ShiftsController < ApplicationController
  before_action :set_team
  before_action :set_client
  before_action :set_shift, only: %i[ edit update destroy ]
  before_action :check_selected, only: %i[ index ]

  def index
    @teams = @office.teams.joins(:clients).distinct.order(:id)
    @clients = @team.clients
    @date = params[:date].present? ? Date.strptime(params[:date], "%Y-%m") : Date.current
    @today = Date.today
    @first_day = @date.beginning_of_month
    @last_day  = @date.end_of_month

    @shifts = @client.shifts.scope_month(@date).includes(:user, client: :team).group_by { |shift| shift.date }
    @date_view = @date.strftime("%m月")
  end

  def new
    @shift = @office.shifts.new(client_id: params[:client_id])
    @date = params[:date]
    @user_clients = @client.users
  end

  def edit
    @user_clients = @client.users
  end

  def create
    unless current_user.office.subscription_active?
      redirect_to subscriptions_index_path, alert: "サブスクリプションが有効ではないため、メッセージを送信できません。"
      return
    end
    @shift = @office.shifts.build(shift_params)
    if @shift.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to team_client_shifts_path(@team, @client), notice: "シフトを作成しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(
                               helpers.dom_id(@shift, :form),
                              partial: "shifts/form",
                              locals: { shift: @shift }
                            ), status: :unprocessable_entity}
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @shift.update(shift_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to team_client_shifts_path(@team, @client), notice: "シフトを更新しました。", status: :see_other }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(
                               helpers.dom_id(@shift, :form),
                              partial: "shifts/form",
                              locals: { shift: @shift }
                            ), status: :unprocessable_entity}
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shift.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to team_client_shifts_path(@team, @client), notice: "シフトを削除しました。", status: :see_other }
    end
  end

  def generate_monthly_shifts
    month = Date.strptime(params[:date], "%Y-%m")
    result = ::Shifts::MonthlyGenerator.new(client: @client, month: month, office: @office).call
    redirect_to team_client_shifts_path(@team, @client, date: month.strftime("%Y-%m")), notice: "シフトを#{result[:created]}件作成しました。"
  end


  private

  def check_selected
    if params[:selected_team_id].present? && params[:selected_team_id] != @team&.id
    requested_team = @office.teams.find_by(id: params[:selected_team_id])
    redirect_to team_client_shifts_path(requested_team, @client, date: params[:date]) and return
    end

    if params[:selected_client_id].present? && params[:selected_client_id] != @client&.id
      requested_client = @team.clients.find_by(id: params[:selected_client_id])
      redirect_to team_client_shifts_path(@team, requested_client, date: params[:date]) and return
    end
  end

  def set_shift
    @shift = @client.shifts.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:user_id, :client_id, :shift_type, :slots, :note, :date, :start_time, :end_time, :work_status)
  end
end
