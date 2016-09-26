class AddHasbyteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_byte, :boolean, default: false
  end
end
