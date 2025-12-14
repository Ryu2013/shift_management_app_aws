class TeamsController < ApplicationController
  before_action :set_team
  before_action :set_client, only: %i[index new edit create update]

  def index
    @teams = @office.teams.includes(:clients, :users).order(:id)
  end

  def new
    @team = @office.teams.build
  end

  def edit
  end

  def create
    @team = @office.teams.build(team_params)
    if @team.save
      redirect_to new_team_client_path(team_id: @team.id), notice: "チームを作成しました。次にクライアントを登録してください。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @team.update(team_params)
      redirect_to teams_path(@team), notice: "チームを更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy!
    redirect_to teams_path, notice: "チームを削除しました。", status: :see_other
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
