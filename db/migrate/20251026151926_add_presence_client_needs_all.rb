class AddPresenceClientNeedsAll < ActiveRecord::Migration[7.2]
  def change
    change_column_null :client_needs, :week, false
    change_column_null :client_needs, :shift_type, false
    change_column_null :client_needs, :start_time, false
    change_column_null :client_needs, :end_time, false
    change_column_null :client_needs, :slots, false
  end
end
