require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'バリデーション' do
    it 'name と office があれば有効であること' do
      team = build(:team)
      expect(team).to be_valid
    end

    it 'name がなければ無効であること' do
      team = build(:team, name: nil)
      team.valid?
      expect(team.errors[:name]).to include('を入力してください。')
    end

    it 'office がなければ無効であること' do
      team = Team.new(name: '部署A')
      team.valid?
      # belongs_to の必須により :office に required エラーが付く
      expect(team.errors[:office]).to include('必須です')
    end
  end

  describe '関連付け（dependent: :destroy）' do
    let!(:team) { create(:team) }

    context 'clients' do
      let!(:client) { create(:client, team: team, office: team.office) }

      it 'team 削除時に clients も削除されること' do
        expect { team.destroy }.to change(Client, :count).by(-1)
      end
    end

    context 'users' do
      let!(:user) { create(:user, team: team, office: team.office) }

      it 'team 削除時に users も削除されること' do
        expect { team.destroy }.to change(User, :count).by(-1)
      end
    end
  end
end
