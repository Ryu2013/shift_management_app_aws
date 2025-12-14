class AddUniqueToOffices < ActiveRecord::Migration[7.2]
  def change
    change_column_null :offices, :name, false
    add_index :offices, :name, unique: true
  end
end
