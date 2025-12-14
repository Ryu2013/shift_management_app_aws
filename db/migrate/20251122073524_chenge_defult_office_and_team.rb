class ChengeDefultOfficeAndTeam < ActiveRecord::Migration[7.2]
  def change
    change_column_default :offices, :name, from: nil, to: "未設定会社名"
    change_column_default :teams, :name, from: nil, to: "未設定部署名"
  end
end
