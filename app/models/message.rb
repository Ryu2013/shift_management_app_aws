class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  belongs_to :office
  validates :content, presence: true
  before_validation :set_office_id
  after_create_commit { broadcast_append_to room }
  after_create_commit :broadcast_room_update

  private

  def broadcast_room_update
    room.users.each do |user|
      broadcast_replace_to user, target: "room_#{room.id}", partial: "rooms/room", locals: { room: room, current_user: user }
      css_class = user.employee? ? "menu margin-mobile" : "menu"
      broadcast_replace_to user, target: "nav_chat_link", partial: "shared/chat_link", locals: { user: user, css_class: css_class }
    end
  end

  def set_office_id
    self.office_id = room.office_id
  end
end
