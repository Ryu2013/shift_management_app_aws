class UserChangeTeamNil < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :team_id, true
  end
end
