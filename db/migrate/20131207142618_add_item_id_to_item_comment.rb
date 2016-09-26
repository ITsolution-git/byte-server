class AddItemIdToItemComment < ActiveRecord::Migration
  def change
    add_column :item_comments, :item_id, :integer
  end
end
