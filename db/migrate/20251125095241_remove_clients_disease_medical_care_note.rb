class RemoveClientsDiseaseMedicalCareNote < ActiveRecord::Migration[7.2]
  def change
    remove_column :clients, :note, :string
    remove_column :clients, :disease, :string
    remove_column :clients, :medical_care, :integer
    remove_column :clients, :public_token, :string
  end
end
