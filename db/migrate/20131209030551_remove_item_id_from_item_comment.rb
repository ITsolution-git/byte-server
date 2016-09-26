class RemoveItemIdFromItemComment < ActiveRecord::Migration
  def up
  	remove_column :item_comments, :item_id
  end

  def down
  end
end
