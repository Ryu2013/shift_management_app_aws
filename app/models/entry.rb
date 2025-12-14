class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :room
  belongs_to :office
  validates :user_id, uniqueness: { scope: :room_id, message: "は既に追加されています" }
end
