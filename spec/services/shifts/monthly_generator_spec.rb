require 'rails_helper'

RSpec.describe Shifts::MonthlyGenerator, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:office) { create(:office) }
  let(:team)   { create(:team, office: office) }
  let(:client) { create(:client, office: office, team: team) }

  # 平日/月曜 09:00-17:00 を2枠
  let!(:need) do
    create(:client_need,
           office: office,
           client: client,
           week: :monday,
           shift_type: :day,
           start_time: '09:00',
           end_time: '17:00',
           slots: 2)
  end

  let(:month) { Date.new(2025, 2, 1) } # 固定月でテストの安定性を担保
  let(:mondays_in_month) do
    (month.beginning_of_month..month.end_of_month).count { |d| d.wday == 1 }
  end

  describe '#call' do
    it '指定月の必要枠数分のShiftを作成し、エラーが空で返る' do
      service = described_class.new(client: client, office: office, month: month)
      result  = service.call

      # 作成件数
      expect(result.created).to eq(mondays_in_month * need.slots)
      expect(result.errors).to be_empty

      # 各対象日の件数がslots分作られていることをざっくり検証
      (month.beginning_of_month..month.end_of_month).select { |d| d.wday == 1 }.each do |date|
        c = Shift.where(office: office, client: client, date: date,
                        shift_type: need.shift_type,
                        start_time: need.start_time,
                        end_time: need.end_time).count
        expect(c).to eq(need.slots)
      end
    end

    it '既存のShiftがある場合は不足分のみ作成する' do
      # 任意の対象日のうち1日分だけ、既に1件作っておく
      target_date = (month.beginning_of_month..month.end_of_month).find { |d| d.wday == 1 }
      create(:shift, office: office, client: client, date: target_date,
                     shift_type: need.shift_type,
                     start_time: need.start_time,
                     end_time: need.end_time)

      service = described_class.new(client: client, office: office, month: month)
      result  = service.call

      # 総作成数は（全月の必要数）-（既存分1件）
      expect(result.created).to eq((mondays_in_month * need.slots) - 1)
      expect(result.errors).to be_empty

      # 既存日の合計件数は slots 分になっていること
      c = Shift.where(office: office, client: client, date: target_date,
                      shift_type: need.shift_type,
                      start_time: need.start_time,
                      end_time: need.end_time).count
      expect(c).to eq(need.slots)
    end

    it '作成中にエラーがあれば全体をロールバックし、errorsに格納する' do
      # 1回だけ例外を起こし、その後は元の動作に戻す
      raised = false
      allow(Shift).to receive(:create!).and_wrap_original do |m, *args|
        unless raised
          raised = true
          raise StandardError, 'boom'
        end
        m.call(*args)
      end

      service = described_class.new(client: client, office: office, month: month)
      result  = service.call

      # 1回でもエラーがあればトランザクションはロールバック
      expect(result.errors).not_to be_empty
      expect(Shift.where(office: office, client: client,
                         shift_type: need.shift_type,
                         start_time: need.start_time,
                         end_time: need.end_time).count).to eq(0)
    end
  end
end
