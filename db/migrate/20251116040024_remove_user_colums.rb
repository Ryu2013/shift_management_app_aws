class RemoveUserColums < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :encrypted_otp_secret, :string
    remove_column :users, :encrypted_otp_secret_iv, :string
    remove_column :users, :encrypted_otp_secret_salt, :string
  end
end
