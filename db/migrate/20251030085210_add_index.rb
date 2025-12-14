class AddIndex < ActiveRecord::Migration[7.2]
  def change
    add_index :user_clients, [ :client_id, :user_id ], unique: true
  end
end
