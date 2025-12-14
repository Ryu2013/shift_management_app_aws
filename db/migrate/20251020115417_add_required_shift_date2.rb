class AddRequiredShiftDate2 < ActiveRecord::Migration[7.2]
  def change
    change_column_null :shifts, :date, false
  end
end
