require 'rails_helper'

RSpec.describe Office, type: :model do
  describe 'バリデーションチェック' do
    it 'nameが存在すれば有効な状態であること' do
      office = build(:office)
      expect(office).to be_valid
    end

    it 'nameがなければ無効な状態であること' do
      office = Office.new(name: nil)
      office.valid?
      expect(office.errors[:name]).to include("を入力してください。")
    end
  end

  describe '関連付け（dependent: :destroy）' do
    let!(:office) { create(:office) }
    context 'users' do
      let!(:user) { create(:user, office: office) }
      it 'office 削除時に users も削除されること' do
        expect { office.destroy }.to change(User, :count).by(-1)
      end
    end
    context 'clients' do
      let!(:client) { create(:client, office: office) }
      it 'office 削除時に clients も削除されること' do
        expect { office.destroy }.to change(Client, :count).by(-1)
      end
    end
    context 'teams' do
      let!(:team) { create(:team, office: office) }
      it 'office 削除時に teams も削除されること' do
        expect { office.destroy }.to change(Team, :count).by(-1)
      end
    end
    context 'user_clients' do
      let!(:user_client) { create(:user_client, office: office) }
      it 'office 削除時に user_clients も削除されること' do
        expect { office.destroy }.to change(UserClient, :count).by(-1)
      end
    end
    context 'client_needs' do
      let!(:client_need) { create(:client_need, office: office) }
      it 'office 削除時に client_needs も削除されること' do
        expect { office.destroy }.to change(ClientNeed, :count).by(-1)
      end
    end
    context 'shifts（clients 経由）' do
      let!(:shift) { create(:shift, office: office) }
      it 'office 削除時に shifts も（clients 経由で）削除されること' do
        expect { office.destroy }.to change(Shift, :count).by(-1)
      end
    end
  end
end
