class UserClientsController < ApplicationController
  before_action :set_team
  before_action :set_client
  before_action :set_user_client, only: %i[ destroy ]

  def new
    if @client.latitude && @client.longitude
      @user_clients = @client&.user_clients.includes(:user, client: :team)
      @users = @team.users.where.not(id: @user_clients.select(:user_id)).sort_by { |u| u.distance_to(@client) || Float::INFINITY }
    else
      @user_clients = @client&.user_clients.includes(:user, client: :team)
      @users = @team.users.where.not(id: @user_clients.select(:user_id))
    end
  end

  def create
    @user_client = @client.user_clients.build(user_client_params)

    respond_to do |format|
      if @user_client.save
        format.html { redirect_to new_team_client_user_client_path(@team, @client), notice: "ユーザークライアントを作成しました。" }
        format.turbo_stream
      else
        @user_clients = @client&.user_clients.includes(:user, client: :team)
        @users = @team.users.sort_by { |u| u.distance_to(@client) }
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @user_client.destroy!

    respond_to do |format|
      format.html { redirect_to team_client_user_clients_path(@team, @client), notice: "ユーザークライアントを削除しました。", status: :see_other }
      format.turbo_stream
    end
  end

  private
    def set_user_client
      @user_client = @client.user_clients.find(params[:id])
    end

    def user_client_params
      params.require(:user_client).permit(:office_id, :user_id, :client_id, :note)
    end
end
