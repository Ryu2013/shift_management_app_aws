FactoryBot.define do
  factory :client do
    association :office
    after(:build) do |client|
      client.office ||= build(:office)
      client.team ||= build(:team, office: client.office)
    end

    sequence(:name) { |n| "顧客#{n}" }
    address { nil }
  end
end
