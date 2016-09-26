class AddIsRegisterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_register, :integer,:default => 0
  end
end
