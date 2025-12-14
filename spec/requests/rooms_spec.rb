require "rails_helper"

RSpec.describe "Rooms", type: :request do
  let(:password) { "password123" }
  let!(:current_user) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:office) { current_user.office }
  let!(:team)   { current_user.team }
  let!(:client) { create(:client, office: office, team: team) }
  let!(:other_user) { create(:user, office: office, team: team) }

  def sign_in_user
    post user_session_path, params: { user: { email: current_user.email, password: password } }
  end

  describe "GET /rooms" do
    it "自分が参加するルームのみを一覧表示する" do
      visible_room = create(:room, name: "Visible Room", office: office)
      create(:entry, room: visible_room, user: current_user, office: office)
      create(:entry, room: visible_room, user: other_user, office: office)

      hidden_room = create(:room, name: "Hidden Room", office: office)
      third_user = create(:user, office: office, team: team)
      create(:entry, room: hidden_room, user: third_user, office: office)

      sign_in_user
      get rooms_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(visible_room.name)
      expect(response.body).not_to include(hidden_room.name)
    end

    it "メッセージの新しい順にルームが表示される" do
      room1 = create(:room, office: office)
      create(:entry, room: room1, user: current_user, office: office)
      create(:entry, room: room1, user: other_user, office: office)
      create(:message, room: room1, user: other_user, office: office, created_at: 1.day.ago)

      room2 = create(:room, office: office)
      create(:entry, room: room2, user: current_user, office: office)
      create(:entry, room: room2, user: other_user, office: office)
      create(:message, room: room2, user: other_user, office: office, created_at: 1.hour.ago)

      room3 = create(:room, office: office)
      create(:entry, room: room3, user: current_user, office: office)
      create(:entry, room: room3, user: other_user, office: office)
      create(:message, room: room3, user: other_user, office: office, created_at: 1.week.ago)

      sign_in_user
      get rooms_path

      expect(response).to have_http_status(:ok)
      # room2 (1 hour ago) -> room1 (1 day ago) -> room3 (1 week ago)
      # HTML内の順序を正規表現などでチェックするか、単にindexで取得したオブジェクトの順序をチェックする
      # viewのテストではないので、assignsを確認するのが確実だが、request specなのでresponse bodyを見るのが一般的
      # ここでは単純にroom id等の出現順序を確認する

      body = response.body
      expect(body.index(room2.name)).to be < body.index(room1.name)
      expect(body.index(room1.name)).to be < body.index(room3.name)
    end
  end

  describe "GET /rooms/new" do
    it "同じ事業所の別ユーザーを選択できる" do
      external_user = create(:user)

      sign_in_user
      get new_room_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(other_user.name)
      expect(response.body).not_to include(current_user.name)
      expect(response.body).not_to include(external_user.name)
    end
  end

  describe "GET /rooms/:id" do
    it "ルームのメッセージを表示できる" do
      room = create(:room, office: office)
      create(:entry, room: room, user: current_user, office: office)
      create(:entry, room: room, user: other_user, office: office)
      message = create(:message, room: room, user: other_user, office: office, content: "Hello room")

      sign_in_user
      get room_path(room)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(message.content)
      expect(response.body).to include(other_user.name)
    end
  end

  describe "POST /rooms" do
    context "既存のルームがある場合" do
      it "新規作成せず既存ルームへリダイレクトする" do
        existing_room = create(:room, office: office)
        create(:entry, room: existing_room, user: current_user, office: office)
        create(:entry, room: existing_room, user: other_user, office: office)

        sign_in_user

        expect do
          post rooms_path, params: { user_id: other_user.id }
        end.to change(Room, :count).by(0).and change(Entry, :count).by(0)

        expect(response).to redirect_to(room_path(existing_room))
        expect(response).to have_http_status(:found)
      end
    end

    context "ルームがまだない場合" do
      it "ルームと参加者のエントリーを作成する" do
        sign_in_user

        expect do
          post rooms_path, params: { user_id: other_user.id }
        end.to change(Room, :count).by(1).and change(Entry, :count).by(2)

        new_room = Room.order(:id).last
        expect(new_room.office).to eq(office)
        expect(new_room.entries.pluck(:user_id)).to match_array([ current_user.id, other_user.id ])
        expect(response).to redirect_to(room_path(new_room))
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "DELETE /rooms/:id" do
    it "ルームと紐づくエントリーを削除する" do
      room = create(:room, office: office)
      create(:entry, room: room, user: current_user, office: office)
      create(:entry, room: room, user: other_user, office: office)

      sign_in_user

      expect do
        delete room_path(room)
      end.to change(Room, :count).by(-1).and change(Entry, :count).by(-2)

      expect(response).to redirect_to(rooms_path)
      expect(response).to have_http_status(:see_other)
    end
  end
end
