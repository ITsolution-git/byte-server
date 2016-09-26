class RemoveAccountNumberFromProfile < ActiveRecord::Migration
  def up
    remove_column :profiles, :account_number
  end

  def down
    add_column :profiles, :account_number, :integer
  end
end
