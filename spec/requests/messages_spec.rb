require "rails_helper"

RSpec.describe "Messages", type: :request do
  let(:password) { "password123" }
  let!(:user) { create(:user, role: :admin, password: password, password_confirmation: password) }
  let!(:other_user) { create(:user, office: user.office) }
  let!(:office) { user.office }
  let!(:room) { create(:room, office: office) }
  let!(:entry) { create(:entry, room: room, user: user) }
  let!(:other_entry) { create(:entry, room: room, user: other_user) }

  def sign_in_user
    post user_session_path, params: { user: { email: user.email, password: password } }
  end

  describe "POST /messages" do
    let(:headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    before { sign_in_user }

    context "サブスク有効" do
      before { office.update!(subscription_status: "active") }

      it "メッセージを作成して200を返す" do
        expect do
          post room_messages_path(room),
            params: { message: { content: "こんにちは" } },
            headers: headers
        end.to change(Message, :count).by(1)

        created_message = Message.order(:id).last
        expect(created_message.content).to eq("こんにちは")
        expect(created_message.user).to eq(user)
        expect(created_message.room).to eq(room)
        expect(created_message.office).to eq(office)
        expect(response).to have_http_status(:ok)
      end

      it "内容が空なら作成されない" do
        expect do
          post room_messages_path(room),
            params: { message: { content: "" } },
            headers: headers
        end.not_to change(Message, :count)

        expect(response).to have_http_status(:ok)
      end

      it "他オフィスのroomなら404を返す" do
        other_room = create(:room) # 別オフィス

        expect do
          post room_messages_path(other_room),
            params: { message: { content: "test" } },
            headers: headers
        end.not_to change(Message, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "サブスク無効" do
    before { office.update!(subscription_status: "canceled") }
      it "メッセージ作成をせずにサブスクページへリダイレクトする" do
        create_list(:user, 3, office: office)
        expect do
          post room_messages_path(room),
            params: { message: { content: "禁止" } },
            headers: headers
        end.not_to change(Message, :count)

        expect(response).to redirect_to(subscriptions_index_path)
        expect(flash[:alert]).to eq("サブスクリプションが有効ではないため、メッセージを送信できません。")
      end
    end
  end
end
