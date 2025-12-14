class AddCurrentPeriodEndToOffices < ActiveRecord::Migration[7.2]
  def change
    add_column :offices, :current_period_end, :datetime
  end
end
