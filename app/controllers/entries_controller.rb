class EntriesController < ApplicationController
  skip_before_action :user_authenticate

  def create
    room = @office.rooms.find_by(id: params[:room_id])
    user = @office.users.find_by(id: params[:user_id])
    @entrie = @office.entries.build(room_id: room.id, user_id: user.id, office_id: @office.id)
    if @entrie.save
    redirect_to edit_room_path(room), notice: "ユーザーを追加しました"
    else
      redirect_to room_path(room), alert: "#{user.name}さんは既に参加しています。"
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    if @entry.room.office_id == @office.id && @entry.room.users.count > 2
      @entry.destroy
      redirect_to edit_room_path(@entry.room), notice: "ユーザーを削除しました", status: :see_other
    else
      redirect_to rooms_path, alert: "チャットから参加者を削除できませんでした。", status: :see_other
    end
  end
end
