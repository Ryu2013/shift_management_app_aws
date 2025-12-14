module Shifts
  class MonthlyGenerator
    # 簡易クラスの生成。keyword_init: trueでキーワード引数で明示的に初期化Result.new(created: created, errors: errors)
    Result = Struct.new(:created, :errors, keyword_init: true)

    def initialize(client:, month:, office:)
      @client = client
      @office = office
      @month  = month
    end

    def call
      created = 0
      errors  = []
      current_month  = @month.beginning_of_month..@month.end_of_month

      Shift.transaction do
        current_month.each do |date|
          needs_for(date).each do |need|
            deficit = need.slots - existing_count(date, need)
            next if deficit <= 0
            deficit.times do
              Shift.create!(
                office:     @office,
                client:     @client,
                date:       date,
                shift_type: need.shift_type,
                start_time: need.start_time,
                end_time:   need.end_time
              )
              created += 1
            end
          rescue => e
            errors << e.message
          end
        end
        raise ActiveRecord::Rollback if errors.any?
      end

      Result.new(created: created, errors: errors)
    end

    private

    def needs_for(date)
      @client.client_needs.where(week: date.wday)
    end

    def existing_count(date, need)
      Shift.where(
        office: @office, client: @client, date: date,
        shift_type: need.shift_type, start_time: need.start_time, end_time: need.end_time
      ).count
    end
  end
end
