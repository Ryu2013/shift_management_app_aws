class ChengeDatetimeToTime < ActiveRecord::Migration[7.2]
  def change
    remove_column :shifts, :start_time, :datetime
    remove_column :shifts, :end_time, :datetime
    add_column :shifts, :start_time, :time
    add_column :shifts, :end_time, :time
  end
end
