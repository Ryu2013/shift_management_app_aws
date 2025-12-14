FactoryBot.define do
  factory :user do
    association :office
    # team は office と同じ事業所に所属させる
    after(:build) do |user|
      user.office ||= build(:office)
      user.team ||= build(:team, office: user.office)
    end

    sequence(:name) { |n| "従業員#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    confirmed_at { Time.current }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
