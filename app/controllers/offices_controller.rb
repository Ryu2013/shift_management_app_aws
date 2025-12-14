class OfficesController < ApplicationController
  before_action :set_team
  before_action :set_client

  def edit
  end

  def update
    if @office.update(office_params)
      redirect_to team_client_shifts_path(@office.teams.first, @office.teams.first.clients.first), notice: "オフィスを更新しました。", status: :see_other
    else
      flash.now[:alert] = "更新に失敗しました。もう一度お試しください。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def office_params
    params.require(:office).permit(:name)
  end
end
