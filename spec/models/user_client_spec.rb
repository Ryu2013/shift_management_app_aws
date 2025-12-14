require 'rails_helper'

RSpec.describe UserClient, type: :model do
  describe 'バリデーション' do
    it 'office・user・client が揃えば有効であること' do
      user_client = build(:user_client)
      expect(user_client).to be_valid
    end

    it 'user がなければ無効であること' do
      user_client = build(:user_client)
      user_client.user = nil
      user_client.valid?
      expect(user_client.errors[:user]).to include('必須です')
    end

    it 'client がなければ無効であること' do
      user_client = build(:user_client)
      user_client.client = nil
      user_client.valid?
      expect(user_client.errors[:client]).to include('必須です')
    end

    it 'office がなければ無効であること' do
      user_client = build(:user_client)
      user_client.user = nil
      user_client.client = nil
      user_client.office = nil
      user_client.valid?
      expect(user_client.errors[:office]).to include('必須です')
    end

    it '同一 client に同一 user は重複できないこと' do
      existing = create(:user_client)
      dup = build(:user_client, user: existing.user, client: existing.client, office: existing.office)
      dup.validate
      expect(dup.errors[:user_id]).to include('はすでに存在します。')
    end
  end

  describe '関連付け（dependent）' do
    context 'office（Office has_many :user_clients, dependent: :destroy）' do
      let!(:office) { create(:office) }
      let!(:user_client) { create(:user_client, office: office) }

      it 'office 削除時に user_client も削除されること' do
        expect { office.destroy }.to change(UserClient, :count).by(-1)
      end
    end

    context 'user（User has_many :user_clients, dependent: :destroy）' do
      let!(:user) { create(:user) }
      let!(:user_client) { create(:user_client, user: user, office: user.office, client: create(:client, office: user.office, team: user.team)) }

      it 'user 削除時に user_client も削除されること' do
        expect { user.destroy }.to change(UserClient, :count).by(-1)
      end
    end

    context 'client（Client has_many :user_clients, dependent: :destroy）' do
      let!(:client) { create(:client) }
      let!(:user) { create(:user, office: client.office, team: client.team) }
      let!(:user_client) { create(:user_client, client: client, user: user, office: client.office) }

      it 'client 削除時に user_client も削除されること' do
        expect { client.destroy }.to change(UserClient, :count).by(-1)
      end
    end
  end

  describe 'コールバック（office_id 自動補完）' do
    it 'office が未設定のとき、client.office で埋まること（client優先）' do
      office_a = create(:office)
      office_b = create(:office)
      client = create(:client, office: office_a)
      user   = create(:user, office: office_b)
      uc = UserClient.new(user: user, client: client, office: nil)
      expect(uc.office_id).to be_nil
      uc.valid? # before_validation で補完
      expect(uc.office_id).to eq(client.office_id)
    end

    it 'office が未設定で client が無いとき、user.office で埋まること（フォールバック）' do
      user = create(:user)
      uc = UserClient.new(user: user, client: nil, office: nil)
      expect(uc.office_id).to be_nil
      uc.valid?
      expect(uc.office_id).to eq(user.office_id)
      expect(uc.errors[:client]).to include('必須です') # client は必須のまま
    end
  end
end
