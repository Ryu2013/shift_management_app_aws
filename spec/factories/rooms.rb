FactoryBot.define do
  factory :room do
    association :office
    sequence(:name) { |n| "Room #{n}" }
  end
end
