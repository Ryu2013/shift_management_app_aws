class Office < ApplicationRecord
    validates :name, presence: true
    has_many :users, dependent: :destroy
    has_many :shifts, dependent: :destroy
    has_many :clients, dependent: :destroy
    has_many :teams, dependent: :destroy
    has_many :user_clients, dependent: :destroy
    has_many :client_needs, dependent: :destroy
    has_many :rooms, dependent: :destroy
    has_many :entries, through: :rooms
    has_many :messages, through: :rooms

  def subscription_active?
    return true if users.count <= 4

    return true if [ "active", "trialing", "past_due", "unpaid" ].include?(subscription_status)

    false
  end
end
