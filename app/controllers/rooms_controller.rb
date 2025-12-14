class RoomsController < ApplicationController
  skip_before_action :user_authenticate
  before_action :set_room, only: %i[edit show destroy update]

  def index
    if current_user.admin?
      @team = @office.teams.joins(:clients).distinct.order(:id).first
      @client = @team.clients.order(:id).first
    end
    @rooms = @office.rooms.joins(:entries)
             .where(entries: { user_id: current_user.id })
             .left_joins(:messages)
             .group(:id)
             .order("MAX(messages.created_at) DESC")
             .includes({ entries: :user }, :users)
  end

  def show
    @messages = @room.messages.order(created_at: :asc)
    @message = @room.messages.new

    entry = @room.entries.find_by(user: current_user)
    @last_read_at = entry&.last_read_at
    entry&.update(last_read_at: Time.current)
  end

  def edit
    @users = @office.users.where.not(id: @room.users.pluck(:id))
  end

  def new
    if current_user.admin?
      @team = @office.teams.joins(:clients).distinct.order(:id).first
      @client = @team.clients.order(:id).first
    end
    @users = @office.users.where.not(id: current_user.id).order(:id)
  end

  def create
    user = @office.users.find(params[:user_id])
    @room = Room
          .joins(:entries)
          .where(office: @office)
          .group("rooms.id")
          .having(<<~SQL, current_user.id, user.id)
            COUNT(entries.id) = 2
            AND SUM(CASE WHEN entries.user_id = ? THEN 1 ELSE 0 END) = 1
            AND SUM(CASE WHEN entries.user_id = ? THEN 1 ELSE 0 END) = 1
          SQL
          .first

    unless @room
      @room = @office.rooms.create
      Entry.create(user: current_user, room: @room, office: @office)
      Entry.create(user: user, room: @room, office: @office)
    end

    redirect_to @room
  end

  def update
    @room.update(room_params)
    redirect_to edit_room_path(@room), notice: "チャット名を更新しました。"
  end

  def destroy
    @room.destroy!
    redirect_to rooms_path, notice: "チャットを削除しました。", status: :see_other
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end

  def set_room
    @room = current_user.rooms.where(rooms: { office_id: @office.id }).find_by(id: params[:id])
    unless @room
      redirect_to rooms_path, alert: "チャットへの参加者のみアクセスできます。" and return
    end
  end
end
