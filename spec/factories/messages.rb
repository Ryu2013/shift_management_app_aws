FactoryBot.define do
  factory :message do
    content { "Hello" }

    after(:build) do |message|
      if message.room
        message.office ||= message.room.office
        message.user ||= build(:user, office: message.room.office)
      elsif message.user
        message.room ||= build(:room, office: message.user.office)
        message.office ||= message.room.office
      else
        message.user ||= build(:user)
        message.room ||= build(:room, office: message.user.office)
        message.office ||= message.room.office
      end
    end
  end
end
