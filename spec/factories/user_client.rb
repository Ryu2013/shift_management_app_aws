FactoryBot.define do
  factory :user_client do
    # office を指定された場合は user/client を同じ office で揃える
    after(:build) do |uc|
      if uc.office
        uc.user   ||= build(:user, office: uc.office)
        uc.client ||= build(:client, office: uc.office)
      else
        uc.user   ||= build(:user)
        uc.client ||= build(:client, office: uc.user.office)
        uc.office ||= uc.user.office
      end
    end
  end
end
