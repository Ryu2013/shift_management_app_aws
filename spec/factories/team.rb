FactoryBot.define do
  factory :team do
    association :office
    sequence(:name) { |n| "部署#{n}" }
  end
end
