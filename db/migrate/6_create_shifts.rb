class CreateShifts < ActiveRecord::Migration[7.2]
  def change
    create_table :shifts, id: :uuid do |t|
      t.references :office, foreign_key: true, null: false, type: :uuid
      t.references :client, foreign_key: true, null: false, type: :uuid
      t.integer :shift_type
      t.integer :slots, null: false, default: 1
      t.string :note
      t.date :date

      t.timestamps
    end
  end
end
