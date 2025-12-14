FactoryBot.define do
  factory :entry do
    after(:build) do |entry|
      if entry.office
        entry.user ||= build(:user, office: entry.office)
        entry.room ||= build(:room, office: entry.office)
      else
        entry.user ||= build(:user)
        entry.room ||= build(:room, office: entry.user.office)
        entry.office ||= entry.user.office
      end
    end
  end
end
