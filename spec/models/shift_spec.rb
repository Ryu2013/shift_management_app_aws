require 'rails_helper'

RSpec.describe Shift, type: :model do
  describe 'バリデーション' do
    it 'office・client・date・start_time・end_time があれば有効であること' do
      shift = build(:shift)
      expect(shift).to be_valid
    end

    it 'user がなくても有効であること（optional: true）' do
      shift = build(:shift)
      expect(shift.user).to be_nil
      expect(shift).to be_valid
    end

    it 'office がなければ無効であること' do
      shift = build(:shift)
      shift.office = nil
      shift.valid?
      expect(shift.errors[:office]).to include('必須です')
    end

    it 'client がなければ無効であること' do
      shift = build(:shift)
      shift.client = nil
      shift.valid?
      expect(shift.errors[:client]).to include('必須です')
    end

    it 'date がなければ無効であること' do
      shift = build(:shift, date: nil)
      shift.valid?
      expect(shift.errors[:date]).to include('を入力してください。')
    end

    it 'start_time がなければ無効であること' do
      shift = build(:shift, start_time: nil)
      shift.valid?
      expect(shift.errors[:start_time]).to include('を入力してください。')
    end

    it 'end_time がなければ無効であること' do
      shift = build(:shift, end_time: nil)
      shift.valid?
      expect(shift.errors[:end_time]).to include('を入力してください。')
    end

    it '同じ日付に同じユーザーを、時間帯が重複する複数のシフトへ割り当てられないこと' do
      user   = create(:user)
      client = create(:client, office: user.office, team: user.team)
      date   = Date.current
      first = create(:shift, office: user.office, client: client, user: user, date: date, start_time: '09:00', end_time: '12:00')

      dup = build(:shift, office: user.office, client: client, user: user, date: date, start_time: '11:00', end_time: '14:00')

      expect(dup).to be_invalid
      expect(dup.errors[:base]).to be_present
    end

    it '同じ日付に同じユーザーでも、時間帯が重複しなければ割り当てられること' do
      user   = create(:user)
      client = create(:client, office: user.office, team: user.team)
      date   = Date.current
      first = create(:shift, office: user.office, client: client, user: user, date: date, start_time: '09:00', end_time: '12:00')

      dup = build(:shift, office: user.office, client: client, user: user, date: date, start_time: '12:00', end_time: '16:00')

      expect(dup).to be_valid
      expect(dup.errors[:base]).to be_empty
    end

    it '23時間59分以上のシフトはエラーになること' do
      shift = build(:shift, office: create(:office), client: create(:client), user: create(:user), date: Date.current, start_time: '00:00', end_time: '23:59')
      expect(shift).to be_invalid
      expect(shift.errors[:base]).to include('24時間を超える場合、次の日と分割してください')
    end

    it '開始と終了が同じ時間の場合（24時間とみなす）もエラーになること' do
      shift = build(:shift, office: create(:office), client: create(:client), user: create(:user), date: Date.current, start_time: '09:00', end_time: '09:00')
      expect(shift).to be_invalid
      expect(shift.errors[:base]).to include('24時間を超える場合、次の日と分割してください')
    end
  end

  describe '関連付け（dependent）' do
    context 'client（Client has_many :shifts, dependent: :destroy）' do
      let!(:client) { create(:client) }
      let!(:shift)  { create(:shift, office: client.office, client: client) }

      it 'client 削除時に shift も削除されること' do
        expect { client.destroy }.to change(Shift, :count).by(-1)
      end
    end

    context 'user（User has_many :shifts, dependent: :nullify）' do
      let!(:user)   { create(:user) }
      let!(:client) { create(:client, office: user.office, team: user.team) }
      let!(:shift)  { create(:shift, office: user.office, client: client, user: user) }

      it 'user 削除時に shift は残り、user_id がNULLになること' do
        expect {
          user.destroy
          shift.reload
        }.to change(Shift, :count).by(0)
        expect(shift.user_id).to be_nil
      end
    end

    context 'office（Office -> clients -> shifts の連鎖削除）' do
      let!(:office) { create(:office) }
      let!(:client) { create(:client, office: office) }
      let!(:shift)  { create(:shift, office: office, client: client) }

      it 'office 削除時に shift も（clients 経由で）削除されること' do
        expect { office.destroy }.to change(Shift, :count).by(-1)
      end
    end
  end

  describe 'スコープ' do
    it 'scope_month は指定月のみ返すこと' do
      month = Date.new(2025, 11, 1)
      in_month   = create(:shift, date: month + 10.days)
      prev_month = create(:shift, date: month - 1.day)
      next_month = create(:shift, date: month.next_month)

      result = Shift.scope_month(month)
      expect(result).to include(in_month)
      expect(result).not_to include(prev_month)
      expect(result).not_to include(next_month)
    end
  end

  describe 'enum' do
    it 'work_status の既定値は not_work であること' do
      shift = build(:shift)
      expect(shift.work_status).to eq('not_work')
    end

    it 'work_status を :work に変更できること' do
      shift = build(:shift)
      shift.work_status = :work
      expect(shift.work_status).to eq('work')
    end
  end

  describe '#duration' do
    it '通常シフト（同日内）の時間を正しく計算すること' do
      shift = build(:shift, start_time: '09:00', end_time: '18:00')
      expect(shift.duration).to eq(9.0)
    end

    it '分単位の時間を正しく計算すること' do
      shift = build(:shift, start_time: '09:00', end_time: '18:30')
      expect(shift.duration).to eq(9.5)
    end

    it '日またぎシフトの時間を正しく計算すること' do
      shift = build(:shift, start_time: '22:00', end_time: '05:00')
      # 22:00 -> 05:00 is 7 hours
      expect(shift.duration).to eq(7.0)
    end

    it '開始・終了時間がない場合は0を返すこと' do
      shift = build(:shift, start_time: nil)
      expect(shift.duration).to eq(0)
    end
  end
end
