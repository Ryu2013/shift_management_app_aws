class ChangeColumnClientneedsTypeToShiftType2 < ActiveRecord::Migration[7.2]
  def change
    rename_column :client_needs, :type, :shift_type
  end
end
