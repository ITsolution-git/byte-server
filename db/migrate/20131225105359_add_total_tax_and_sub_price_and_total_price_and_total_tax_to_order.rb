class AddTotalTaxAndSubPriceAndTotalPriceAndTotalTaxToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :total_tax, :float, :default => 0
  	add_column :orders, :total_price, :float, :default => 0
  	add_column :orders, :sub_price, :float, :default => 0
  	rename_column :orders, :tip, :total_tip
  end
end