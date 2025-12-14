class UsersTeamNullTreu < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :team_id, false
  end
end
