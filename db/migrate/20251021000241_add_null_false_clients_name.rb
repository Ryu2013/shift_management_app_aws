class AddNullFalseClientsName < ActiveRecord::Migration[7.2]
  def change
    change_column_null :clients, :name, false
  end
end
