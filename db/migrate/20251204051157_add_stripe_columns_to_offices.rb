class AddStripeColumnsToOffices < ActiveRecord::Migration[7.2]
  def change
    add_column :offices, :stripe_customer_id, :string
    add_column :offices, :stripe_subscription_id, :string
    add_column :offices, :subscription_status, :string
  end
end
