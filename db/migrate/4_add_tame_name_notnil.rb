class AddTameNameNotnil < ActiveRecord::Migration[7.2]
  def change
    change_column_null :teams, :name, false
  end
end
