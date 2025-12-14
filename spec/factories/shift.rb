FactoryBot.define do
  factory :shift do
    association :office
    after(:build) do |shift|
      shift.office ||= build(:office)
      shift.client ||= build(:client, office: shift.office)
    end

    date { Date.current }
    start_time { "09:00" }
    end_time { "17:00" }
    shift_type { :day }
  end
end
