class ClientNeed < ApplicationRecord
  belongs_to :office
  belongs_to :client
  before_validation :set_office_id, if: -> { client.present? }

  validates :shift_type, :week, :start_time, :end_time, :slots, presence: true
  validate :duration_limit


  enum :shift_type, { day: 0, night: 1 }
  enum :week, { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }

  after_create_commit  -> { broadcast_append_to  stream_key, target: "client_needs_#{week}" if stream_key }
  after_update_commit  -> { broadcast_replace_to stream_key if stream_key }
  after_destroy_commit -> { broadcast_remove_to  stream_key if stream_key }

  private
  def set_office_id
    self.office_id = client.office_id
  end

  def duration_limit
    return unless start_time && end_time

    diff_seconds = if end_time <= start_time
                     (end_time + 1.day) - start_time
    else
                     end_time - start_time
    end

    if diff_seconds >= 23.hours + 59.minutes
      errors.add(:base, "24時間を超える場合、次の日と分割してください")
    end
  end

  def stream_key = [ client, :client_needs ]
end
