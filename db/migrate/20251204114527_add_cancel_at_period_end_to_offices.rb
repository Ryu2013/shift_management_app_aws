class AddCancelAtPeriodEndToOffices < ActiveRecord::Migration[7.2]
  def change
    add_column :offices, :cancel_at_period_end, :boolean
  end
end
