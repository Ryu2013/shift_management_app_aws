class AddForeignKeyUserTeams < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :team, null: false, foreign_key: true, type: :uuid
  end
end
