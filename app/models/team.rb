class Team < ApplicationRecord
  belongs_to :office
  has_many :clients, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :name, presence: true
end
