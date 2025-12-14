class CreateEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :room, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
