class AddIsCancelToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :is_cancel, :integer, :default=>0
  end
end
