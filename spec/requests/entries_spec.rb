require 'rails_helper'

RSpec.describe "エントリ", type: :request do
  let(:office) { create(:office) }
  let(:password) { "password123" }
  let(:user) { create(:user, office: office, password: password, password_confirmation: password) }
  let(:other_user) { create(:user, office: office) }
  let(:room) { create(:room, office: office) }

  before do
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  describe "POST /rooms/:room_id/entries" do
    context "有効なユーザーを追加する場合" do
      it "部屋にユーザーを追加する" do
        puts "🍌🍌"
        expect {
          post room_entries_path(room), params: { user_id: other_user.id  }
        }.to change(Entry, :count).by(1)
        expect(response).to redirect_to(edit_room_path(room))
        expect(flash[:notice]).to eq("ユーザーを追加しました")
      end
    end

    context "既に参加しているユーザーを追加する場合" do
      before do
        create(:entry, room: room, user: other_user, office: office)
      end

      it "ユーザーを追加しない" do
        expect {
          post room_entries_path(room), params: { user_id: other_user.id }
        }.not_to change(Entry, :count)
        expect(response).to redirect_to(room_path(room))
        expect(flash[:alert]).to eq("#{other_user.name}さんは既に参加しています。")
      end
    end
  end
end
