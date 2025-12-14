class RemoveUserPrefPerWeekAndCommute < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :commute, :string
    remove_column :users, :pref_per_week, :integer
  end
end
