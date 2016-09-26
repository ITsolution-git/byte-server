class AddPriceAndRedemptionValueToOrderItem < ActiveRecord::Migration
  def change
  	add_column :order_items, :price, :float, :default => 0
  	add_column :order_items, :redemption_value, :integer, :default => 0
  	remove_column :order_items, :paid_type
  end
end