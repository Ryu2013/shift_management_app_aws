class Client < ApplicationRecord
  belongs_to :office
  belongs_to :team
  has_many :shifts, dependent: :destroy
  has_many :client_needs, dependent: :destroy
  has_many :user_clients, dependent: :destroy
  accepts_nested_attributes_for :user_clients, allow_destroy: true
  has_many :users, through: :user_clients
  validates :name, presence: true
  geocoded_by :address, latitude: :latitude, longitude: :longitude
  after_validation :geocode, if: :address_changed?

  def google_maps_route_url_template
    return nil unless latitude.present? && longitude.present?

    destination = "#{self.latitude},#{self.longitude}"

    "https://www.google.com/maps/dir/?api=1&destination=#{self.latitude},#{self.longitude}&travelmode=driving"
  end
end
