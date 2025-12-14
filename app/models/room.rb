class Room < ApplicationRecord
  belongs_to :office
  has_many :entries, dependent: :destroy
  has_many :users, through: :entries
  has_many :messages, dependent: :destroy

  def has_unread_messages?(user)
    entry = entries.find_by(user: user)
    return false unless entry
    scope = messages.where.not(user_id: user.id)
    if entry.last_read_at
      scope.where("created_at > ?", entry.last_read_at).exists?
    else
      scope.exists?
    end
  end
end
