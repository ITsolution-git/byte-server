class AddMaxQuantityToOrderComboItem < ActiveRecord::Migration
  def change
    add_column :order_item_combos, :max_quantity, :integer, :default => 0
  end
end
