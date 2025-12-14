class User < ApplicationRecord
  devise :invitable, :registerable,
         :validatable, :confirmable, :lockable, :two_factor_authenticatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]
  devise :pwned_password unless Rails.env.test?
  encrypts :otp_secret

  belongs_to :office
  belongs_to :team
  has_many :clients, through: :user_clients
  has_many :user_clients, dependent: :destroy
  has_many :shifts, dependent: :nullify
  has_many :entries, dependent: :destroy
  has_many :rooms, through: :entries
  has_many :messages, dependent: :destroy
  validates :name, presence: true
  enum :role, { employee: 0, admin: 1 }

  delegate :subscription_active?, to: :office, allow_nil: true
  validate :validate_user_limit, on: :create

  has_one_attached :icon

  geocoded_by :address, latitude: :latitude, longitude: :longitude
  after_validation :geocode, if: :address_changed?

  def validate_user_limit
    return unless office.present?
    current_count = office.users.count

    if current_count >= 5 && !subscription_active?
      errors.add(:base, "無料プランの上限（5名）に達しました。メンバーを追加するにはサブスクリプション登録が必要です。")
    end
  end

  # アイコンを表示するためのメソッド
  def icon_url
    if icon.attached?
      icon
    else
      "default_icon.png"
    end
  end

  def has_unread_messages?
    rooms.any? { |room| room.has_unread_messages?(self) }
  end

  private
  # OmniAuth
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      # confirmed_at を設定してメール確認をスキップ
      user.confirmed_at = Time.current
      # office と team は既存ユーザーから引き継ぐか、デフォルトを設定
      user.office = Office.create
      user.team = Team.create(office: user.office)
      user.role = :admin
    end
  end
end
