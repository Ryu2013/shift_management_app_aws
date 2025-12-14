class AddUniqueIndexToShiftsUserPerDay < ActiveRecord::Migration[7.2]
  def change
    # 同一ユーザーが同日に複数のシフトに割り当てられないようDB制約を追加
    # user_id が NULL の行は対象外（未割当シフトを許容）
    add_index :shifts, [ :user_id, :date ], unique: true, where: "user_id IS NOT NULL", name: "index_shifts_on_user_id_and_date_unique"
  end
end
