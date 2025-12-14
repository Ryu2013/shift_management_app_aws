class MessagesController < ApplicationController
  skip_before_action :user_authenticate

  def create
    unless current_user.office.subscription_active?
      redirect_to subscriptions_index_path, alert: "サブスクリプションが有効ではないため、メッセージを送信できません。"
      return
    end
    @room = current_user.rooms.where(rooms: { office_id: @office.id }).find_by(id: params[:room_id])
    unless @room
      head :not_found
      return
    end
    @message = @room.messages.build(message_params)
    @message.user = current_user
    @message.save
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
