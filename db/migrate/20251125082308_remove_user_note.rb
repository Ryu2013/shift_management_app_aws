class RemoveUserNote < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :note, :string
  end
end
