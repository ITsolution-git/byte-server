class AddItemIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :item_id, :integer
  end
end
