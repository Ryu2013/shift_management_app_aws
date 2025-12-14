class RemoveShiftsIndexUserDate < ActiveRecord::Migration[7.2]
  def change
    remove_index :shifts, column: [ :user_id, :date ], name: "index_shifts_on_user_id_and_date_unique"
  end
end
