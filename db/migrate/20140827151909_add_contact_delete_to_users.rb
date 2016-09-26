class AddContactDeleteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contact_delete, :integer, :default => 0
  end
end
