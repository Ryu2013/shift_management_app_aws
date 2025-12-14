class AddUniqueToStartTimeEndTime < ActiveRecord::Migration[7.2]
  def change
    change_column_null :shifts, :start_time, false
    change_column_null :shifts, :end_time, false
  end
end
