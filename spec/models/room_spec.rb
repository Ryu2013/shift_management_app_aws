require 'rails_helper'

RSpec.describe Room, type: :model do
  describe '#has_unread_messages?' do
    let(:office) { create(:office) }
    let(:user) { create(:user, office: office) }
    let(:other_user) { create(:user, office: office) } # メッセージ送信者
    let(:room) { create(:room, office: office) }
    let!(:entry) { create(:entry, room: room, user: user, office: office, last_read_at: last_read_at) }
    let!(:other_entry) { create(:entry, room: room, user: other_user, office: office) }

    context 'last_read_atがnilの場合' do
      let(:last_read_at) { nil }

      it 'メッセージがない場合、falseを返す' do
        expect(room.has_unread_messages?(user)).to be_falsey
      end

      it 'メッセージが存在する場合、trueを返す' do
        create(:message, room: room, user: other_user, office: office)
        expect(room.has_unread_messages?(user)).to be_truthy
      end
    end

    context 'last_read_atが設定されている場合' do
      let(:last_read_at) { 1.hour.ago }

      it '新しいメッセージがない場合、falseを返す' do
        create(:message, room: room, user: other_user, office: office, created_at: 2.hours.ago)
        expect(room.has_unread_messages?(user)).to be_falsey
      end

      it '新しいメッセージが存在する場合、trueを返す' do
        create(:message, room: room, user: other_user, office: office, created_at: 30.minutes.ago)
        expect(room.has_unread_messages?(user)).to be_truthy
      end
    end
  end
end
