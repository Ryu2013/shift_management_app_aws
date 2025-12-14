# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :set_team
  before_action :set_client
  before_action :set_user, only: [ :edit, :update, :destroy ]

  def index
    if params[:selected_team_id].present?
      requested_team = @office.teams.find_by(id: params[:selected_team_id])
      if requested_team && requested_team.id != @team&.id
        redirect_to team_users_path(requested_team) and return
      end
    end

    @users = @team.users.all.order(:name)
    @teams = @office.teams.joins(:users).distinct.order(:id)
  end

  def edit
    @teams = @office.teams
  end

  def update
    attributes = user_params.compact_blank

    if attributes[:password].blank?
      attributes.delete(:password)
      attributes.delete(:password_confirmation)
    end

    if attributes[:email].blank?
      attributes.delete(:email)
    end

    if @user.update(attributes)
      redirect_to team_users_path(@user.team), notice: "従業員情報を更新しました。", status: :see_other
    else
      @teams = @office.teams
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to team_users_path(current_user.team), notice: "従業員を削除しました。", status: :see_other
  end

  private
    def set_user
      @user = @office.users.find(params[:id])
    end

    def user_params
      # 1. 常に許可する基本のパラメータ
      permitted_attributes = [ :team_id, :address, :name, :email, :password, :password_confirmation, :icon ]

      # 2. 「自分自身ではない」場合のみ、role の更新を許可リストに加える
      # ※ @user は edit/update アクションの set_user で定義されている前提です
      if current_user != @user
        permitted_attributes << :role
      end

      # 3. 許可されたリストを使ってデータをフィルタリング
      params.require(:user).permit(permitted_attributes)
    end
end
