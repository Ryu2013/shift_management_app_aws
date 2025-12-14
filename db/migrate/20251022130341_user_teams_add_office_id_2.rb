class UserTeamsAddOfficeId2 < ActiveRecord::Migration[7.2]
  def change
    add_reference :user_teams, :office, null: false, foreign_key: true, type: :uuid
  end
end
