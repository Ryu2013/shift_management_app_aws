class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams, id: :uuid do |t|
      t.references :office, foreign_key: true, null: false, type: :uuid
      t.string :name

      t.timestamps
    end
  end
end
