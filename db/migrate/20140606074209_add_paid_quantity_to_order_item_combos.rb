class AddPaidQuantityToOrderItemCombos < ActiveRecord::Migration
  def change
    add_column :order_item_combos, :paid_quantity, :integer,:default => -1
  end
end
