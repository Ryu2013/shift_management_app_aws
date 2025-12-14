class ChangeColumnDefaultOfficesAndTeams < ActiveRecord::Migration[7.2]
  def change
    change_column_default :offices, :name, from: nil, to: "未設定"
    change_column_default :teams, :name, from: nil, to: "未設定"
  end
end
