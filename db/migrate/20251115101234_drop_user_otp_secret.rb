class DropUserOtpSecret < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :otp_secret, :string
  end
end
