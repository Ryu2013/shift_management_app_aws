FactoryBot.define do
  factory :office do
    sequence(:name) { |n| "テストオフィス#{n}" }
  end
end
