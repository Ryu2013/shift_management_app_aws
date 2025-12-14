class ClientsTeamNullFales < ActiveRecord::Migration[7.2]
  def change
     change_column_null :clients, :team_id, false
  end
end
