class AddAccountNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :account_number, :integer
    add_column :locations, :active, :boolean, :default => true
  end
end
