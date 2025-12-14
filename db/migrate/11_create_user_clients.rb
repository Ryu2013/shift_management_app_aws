class CreateUserClients < ActiveRecord::Migration[7.2]
  def change
    create_table :user_clients, id: :uuid do |t|
      t.references :office, foreign_key: true, null: false, type: :uuid
      t.references :user, foreign_key: true, null: false, type: :uuid
      t.references :client, foreign_key: true, null: false, type: :uuid
      t.string :note

      t.timestamps
    end
  end
end
