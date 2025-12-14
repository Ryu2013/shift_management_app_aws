class RemoveUniqueIndexFromOfficesName < ActiveRecord::Migration[7.2]
  def change
      remove_index :offices, name: "index_offices_on_name"
  end
end
