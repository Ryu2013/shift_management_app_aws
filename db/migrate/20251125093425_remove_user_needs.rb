class RemoveUserNeeds < ActiveRecord::Migration[7.2]
  def change
    drop_table :user_needs
  end
end
