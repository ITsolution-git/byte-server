class AddReadToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :read, :integer, :default => 0
  end
end
