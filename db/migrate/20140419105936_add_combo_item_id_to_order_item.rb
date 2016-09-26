class AddComboItemIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :combo_item_id, :integer
  end
end
