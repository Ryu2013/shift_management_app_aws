class ClientsTeamNullTreu < ActiveRecord::Migration[7.2]
  def change
    change_column_null :clients, :team_id, true
  end
end
