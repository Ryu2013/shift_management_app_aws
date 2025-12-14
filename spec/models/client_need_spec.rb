require 'rails_helper'

RSpec.describe ClientNeed, type: :model do
  describe 'バリデーション' do
    it '必須項目が揃えば有効であること' do
      client_need = build(:client_need)
      expect(client_need).to be_valid
    end

    it 'client がなければ無効であること' do
      client_need = build(:client_need)
      client_need.client = nil
      client_need.valid?
      expect(client_need.errors[:client]).to include('必須です')
    end

    it 'office がなければ無効であること（client に office が無い場合）' do
      client_need = build(:client_need)
      client_need.office = nil
      client_need.valid?
      expect(client_need.errors[:office]).to include('必須です')
    end

    it 'week がなければ無効であること' do
      client_need = build(:client_need, week: nil)
      client_need.valid?
      expect(client_need.errors[:week]).to include('を入力してください。')
    end

    it 'shift_type がなければ無効であること' do
      client_need = build(:client_need, shift_type: nil)
      client_need.valid?
      expect(client_need.errors[:shift_type]).to include('を入力してください。')
    end

    it 'start_time がなければ無効であること' do
      client_need = build(:client_need, start_time: nil)
      client_need.valid?
      expect(client_need.errors[:start_time]).to include('を入力してください。')
    end

    it 'end_time がなければ無効であること' do
      client_need = build(:client_need, end_time: nil)
      client_need.valid?
      expect(client_need.errors[:end_time]).to include('を入力してください。')
    end

    it 'slots がなければ無効であること' do
      client_need = build(:client_need, slots: nil)
      client_need.valid?
      expect(client_need.errors[:slots]).to include('を入力してください。')
    end

    it '23時間59分以上のシフトはエラーになること' do
      client_need = build(:client_need, start_time: '00:00', end_time: '23:59')
      expect(client_need).to be_invalid
      expect(client_need.errors[:base]).to include('24時間を超える場合、次の日と分割してください')
    end

    it '開始と終了が同じ時間の場合（24時間とみなす）もエラーになること' do
      client_need = build(:client_need, start_time: '09:00', end_time: '09:00')
      expect(client_need).to be_invalid
      expect(client_need.errors[:base]).to include('24時間を超える場合、次の日と分割してください')
    end
  end

  describe '関連付け（dependent）' do
    context 'client（Client has_many :client_needs, dependent: :destroy）' do
      let!(:client) { create(:client) }
      let!(:client_need) { create(:client_need, client: client, office: client.office) }

      it 'client 削除時に client_need も削除されること' do
        expect { client.destroy }.to change(ClientNeed, :count).by(-1)
      end
    end

    context 'office（Office has_many :client_needs, dependent: :destroy）' do
      let!(:office) { create(:office) }
      let!(:client_need) { create(:client_need, office: office) }

      it 'office 削除時に client_need も削除されること' do
        expect { office.destroy }.to change(ClientNeed, :count).by(-1)
      end
    end
  end

  describe 'enum' do
    it 'shift_type は day/night を受理すること' do
      cn_day = build(:client_need, shift_type: :day)
      cn_night = build(:client_need, shift_type: :night)
      expect(cn_day.shift_type).to eq('day')
      expect(cn_night.shift_type).to eq('night')
    end

    it 'week は定義済みの曜日を受理すること' do
      cn = build(:client_need, week: :monday)
      expect(cn.week).to eq('monday')
    end

    it '未定義の shift_type は拒否すること' do
      cn = build(:client_need)
      expect { cn.shift_type = :invalid }.to raise_error(ArgumentError)
    end

    it '未定義の week は拒否すること' do
      cn = build(:client_need)
      expect { cn.week = :funday }.to raise_error(ArgumentError)
    end
  end

  describe 'コールバック（office_id 自動補完）' do
    it 'office が未設定のとき、client.office で埋まること' do
      client = create(:client)
      cn = ClientNeed.new(
        client: client,
        office: nil,
        week: :monday,
        shift_type: :day,
        start_time: '09:00',
        end_time: '17:00',
        slots: 1
      )
      expect(cn.office_id).to be_nil
      cn.valid? # before_validation で補完
      expect(cn.office_id).to eq(client.office_id)
    end
  end
end
