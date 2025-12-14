FactoryBot.define do
  factory :user_need do
    association :user

    week { :monday }
    start_time { "09:00" }
    end_time   { "17:00" }

    # office が渡された場合は user 側も合わせて整合性を取る
    after(:build) do |user_need|
      if user_need.office && user_need.user
        user_need.user.office = user_need.office
        user_need.user.team ||= build(:team, office: user_need.office)
        user_need.user.team.office = user_need.office
      elsif user_need.user&.office
        user_need.office ||= user_need.user.office
      else
        user_need.user ||= build(:user)
        user_need.office ||= user_need.user.office
      end
    end
  end
end
