class UserClient < ApplicationRecord
  belongs_to :office
  belongs_to :user
  belongs_to :client
  before_validation :set_office_id
  validates :user_id, uniqueness: { scope: :client_id }

  after_create_commit  :broadcast_create, if: -> { stream_key.present? }
  after_destroy_commit :broadcast_remove, if: -> { stream_key.present? }

  private
    def set_office_id
    self.office_id ||= client&.office_id || user&.office_id
    end

    def stream_key
      return if client.nil?
      [ client, :user_clients ]
    end

    def broadcast_create
        broadcast_remove_to stream_key, target: "not_user_#{user.id}"
        broadcast_append_to stream_key
    end

    def broadcast_remove
        broadcast_remove_to stream_key
        broadcast_append_to stream_key,
        target: "not_users",
        partial: "user_clients/not_user_client",  # 使いたいパーシャルのパス
        locals: { u: self.user, team: self.client.team, client: self.client } # パーシャル内で使う変数
    end
end
