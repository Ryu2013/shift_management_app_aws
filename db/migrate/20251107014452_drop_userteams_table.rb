class DropUserteamsTable < ActiveRecord::Migration[7.2]
  def change
    drop_table :user_teams
  end
end
