class Employee::ShiftsController < ApplicationController
  skip_before_action :user_authenticate
  before_action :set_user

  def index
    @date = params[:date].present? ? Date.strptime(params[:date], "%Y-%m") : Date.current
    @today = Date.today
    @first_day = @date.beginning_of_month
    @last_day  = @date.end_of_month

    @shifts = @user.shifts.scope_month(@date).includes(:client).group_by { |shift| shift.date }
    @date_view = @date.strftime("%m月")
    @today_shifts = @user.shifts.where(date: @today).order(:start_time)

    monthly_shifts = @user.shifts.scope_month(@date)
    @total_hours = monthly_shifts.sum(&:duration).round(2)
    @worked_hours = monthly_shifts.work.sum(&:duration).round(2)
  end

  def update
    @shift = @user.shifts.find(params[:id])
    if @shift.update(shift_params)
      redirect_to employee_shifts_path, notice: "シフトを更新しました。"
    else
      @date = Date.current
      @today = Date.today
      @first_day = @date.beginning_of_month
      @last_day  = @date.end_of_month
      @shifts = @user.shifts.scope_month(@date).group_by { |shift| shift.date }
      @date_view = @date.strftime("%m月")
      @today_shifts = @user.shifts.where(date: @today).order(:start_time)

      monthly_shifts = @user.shifts.scope_month(@date)
      @total_hours = monthly_shifts.sum(&:duration)
      @worked_hours = monthly_shifts.work.sum(&:duration)

      flash.now[:alert] = "シフトの更新に失敗しました。"
      render :index, status: :unprocessable_entity
    end
  end

  private
  def set_user
    if current_user.admin?
      @user = @office.users.find(params[:user_id])
    else
      @user = current_user
    end
  end

  def shift_params
    params.require(:shift).permit(:work_status)
  end
end
