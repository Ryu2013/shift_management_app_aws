class AddOfficeRefToChatTables < ActiveRecord::Migration[7.2]
  def change
    add_reference :rooms, :office, null: false, foreign_key: true, type: :uuid
    add_reference :entries, :office, null: false, foreign_key: true, type: :uuid
    add_reference :messages, :office, null: false, foreign_key: true, type: :uuid
  end
end
