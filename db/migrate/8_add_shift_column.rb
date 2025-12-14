class AddShiftColumn < ActiveRecord::Migration[7.2]
  def change
    add_reference :shifts, :user, foreign_key: true, type: :uuid
    add_column :shifts, :is_escort, :boolean, default: false
    add_column :shifts, :work_status, :integer, default: 0
    add_column :shifts, :start_time, :datetime
    add_column :shifts, :end_time, :datetime
  end
end
