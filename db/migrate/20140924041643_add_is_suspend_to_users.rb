class AddIsSuspendToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_suspended, :integer, :default => 0
  end
end
