class ChangeUsePointToDecimalFromOrderItem < ActiveRecord::Migration
  def up
  	change_column :order_items, :use_point, :float,:default=>0
  	remove_column :order_items, :item_id
  end

  def down
  end
end