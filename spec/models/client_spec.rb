require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'バリデーション' do
    it 'name・office・team があれば有効であること' do
      client = build(:client)
      expect(client).to be_valid
    end

    it 'name がなければ無効であること' do
      client = build(:client, name: nil)
      client.valid?
      expect(client.errors[:name]).to include('を入力してください。')
    end

    it 'office がなければ無効であること' do
      client = Client.new(name: '顧客A', team: build(:team))
      client.valid?
      expect(client.errors[:office]).to include('必須です')
    end

    it 'team がなければ無効であること' do
      client = Client.new(name: '顧客A', office: build(:office))
      client.valid?
      expect(client.errors[:team]).to include('必須です')
    end
  end

  describe '関連付け（dependent: :destroy）' do
    let!(:client) { create(:client) }

    context 'shifts' do
      let!(:shift) { create(:shift, client: client, office: client.office) }

      it 'client 削除時に shifts も削除されること' do
        expect { client.destroy }.to change(Shift, :count).by(-1)
      end
    end

    context 'client_needs' do
      let!(:client_need) { create(:client_need, client: client, office: client.office) }

      it 'client 削除時に client_needs も削除されること' do
        expect { client.destroy }.to change(ClientNeed, :count).by(-1)
      end
    end

    context 'user_clients' do
      let!(:user) { create(:user, office: client.office, team: client.team) }
      let!(:user_client) { create(:user_client, client: client, user: user, office: client.office) }

      it 'client 削除時に user_clients も削除されること' do
        expect { client.destroy }.to change(UserClient, :count).by(-1)
      end
    end
  end

  describe 'accepts_nested_attributes_for :user_clients' do
    it 'create時に user_clients を同時作成できること' do
      office = create(:office)
      team   = create(:team, office: office)
      user   = create(:user, office: office, team: team)

      expect {
        Client.create!(
          office: office,
          team: team,
          name: '顧客A',
          user_clients_attributes: [ { user_id: user.id } ]
        )
      }.to change(UserClient, :count).by(1)
    end

    it 'update時に _destroy: true で user_clients を削除できること' do
      client = create(:client)
      user   = create(:user, office: client.office, team: client.team)
      uc     = create(:user_client, client: client, user: user, office: client.office)

      expect {
        client.update!(
          user_clients_attributes: [ { id: uc.id, _destroy: true } ]
        )
      }.to change(UserClient, :count).by(-1)
    end
  end
end
