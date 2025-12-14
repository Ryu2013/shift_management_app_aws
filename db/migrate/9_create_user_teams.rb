class CreateUserTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :user_teams, id: :uuid do |t|
      t.references :team, foreign_key: true, null: false, type: :uuid
      t.references :user, foreign_key: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
