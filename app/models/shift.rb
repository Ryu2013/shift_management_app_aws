class Shift < ApplicationRecord
  belongs_to :office
  belongs_to :client
  belongs_to :user, optional: true
  validates :start_time, :end_time, presence: true
  validates :date, presence: true
  # 1日に同じユーザーを複数のシフトに割り当てない（日本語メッセージ付き）
  validate :user_unique_per_date, if: -> { user_id.present? && date.present? }
  validate :duration_limit

  enum :shift_type, { day: 0, night: 1, escort: 2 }
  enum :work_status, { not_work: 0, work: 1 }
  delegate :subscription_active?, to: :office, allow_nil: true
  scope :scope_month, ->(month) { where(date: month.beginning_of_month..month.end_of_month) }

  def duration
    return 0 unless start_time && end_time

    if end_time < start_time
      ((end_time + 1.day) - start_time) / 3600.0
    else
      (end_time - start_time) / 3600.0
    end
  end

  after_create_commit  -> { broadcast_append_to stream_key, target: "shifts_#{date}" }, if: -> { stream_key.present? }
  after_update_commit  :broadcast_shift_update, if: -> { stream_key.present? }
  after_destroy_commit -> { broadcast_remove_to stream_key }, if: -> { stream_key.present? }

  private
  def validate_user_limit
    return unless office.present?
    current_count = office.users.count

    if current_count >= 5 && !subscription_active?
      errors.add(:base, "無料プランの上限（5名）に達しました。メンバーを追加するにはサブスクリプション登録が必要です。")
    end
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


  def stream_key
    return if client.nil?
    [ client, :shifts ]
  end

  def broadcast_shift_update
    if saved_change_to_date?
      broadcast_remove_to stream_key
      broadcast_append_to stream_key, target: "shifts_#{date}"
    else
      broadcast_replace_to stream_key
    end
  end

  def user_unique_per_date
    return unless user_id.present?
    conflict = Shift.where(user_id: user_id, date: date)
                   .where.not(id: id)
                   .where("start_time < ? AND end_time > ?", end_time, start_time)
                   .first

    return unless conflict

    # エラーメッセージを追加
    errors.add(:base, I18n.t("errors.messages.time_slot_conflict",
                              user_name: user&.name,
                              date: I18n.l(date, format: :long),
                              start_time: I18n.l(start_time, format: :time),
                              end_time: I18n.l(end_time, format: :time),
                              conflict_client: conflict.client&.name,
                              conflict_start: I18n.l(conflict.start_time, format: :time),
                              conflict_end: I18n.l(conflict.end_time, format: :time)))
  end
end
