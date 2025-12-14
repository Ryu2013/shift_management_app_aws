class AddLastReadAtToEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :entries, :last_read_at, :datetime
  end
end
