class ClientsController < ApplicationController
  before_action :set_team
  before_action :set_client, only: %i[index edit update destroy]

  def index
    if params[:selected_team_id].present?
      requested_team = @office.teams.find_by(id: params[:selected_team_id])
      if requested_team && requested_team.id != @team&.id
        redirect_to team_clients_path(requested_team) and return
      end
    end

    @clients = @team.clients.all.order(:name)
    @teams = @office.teams.joins(:clients).distinct.order(:id)
  end

  def new
    @client = @office.clients.build(team: @team)
    @teams = @office.teams.all
  end

  def edit
    @teams = @office.teams.all
    @client.user_clients.build(office: @office)
    @users = @team.users
  end

  def create
    @client = @office.clients.new(client_params)
    if @client.save
      redirect_to team_clients_path(@client.team), notice: "クライアントを作成しました。"
    else
      @needs_by_week = @client.client_needs.order(:week, :shift_type, :start_time).group_by(&:week)
      @users = @team.users
      @teams = @office.teams.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(client_params)
      redirect_to team_clients_path(@client.team), notice: "クライアントを更新しました。", status: :see_other
    else
      @needs_by_week = @client.client_needs.order(:week, :shift_type, :start_time).group_by(&:week)
      @users = @team.users
      @teams = @office.teams.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to team_clients_path(@team), notice: "クライアントを削除しました。", status: :see_other
  end

  private


  def client_params
    params.require(:client).permit(:team_id, :name, :address, user_clients_attributes: [ :id, :user_id, :note, :_destroy ])
  end
end
