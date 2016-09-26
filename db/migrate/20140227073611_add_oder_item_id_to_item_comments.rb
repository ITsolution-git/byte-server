class AddOderItemIdToItemComments < ActiveRecord::Migration
  def change
    add_column :item_comments, :order_item_id, :integer
  end
end
