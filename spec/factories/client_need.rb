FactoryBot.define do
  factory :client_need do
    after(:build) do |client_need|
      client_need.office ||= build(:office)
      client_need.client ||= build(:client, office: client_need.office)
    end

    week { :monday }
    shift_type { :day }
    start_time { "09:00" }
    end_time   { "17:00" }
    slots      { 1 }
  end
end
