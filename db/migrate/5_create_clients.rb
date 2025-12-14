class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients, id: :uuid do |t|
      t.references :office, foreign_key: true, null: false, type: :uuid
      t.references :team, foreign_key: true, null: false, type: :uuid
      t.integer :medical_care
      t.string :name
      t.string :email
      t.string :address
      t.string :disease
      t.string :public_token
      t.string :note

      t.timestamps
    end
  end
end
