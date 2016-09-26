class RemoveItemIdFromItemFavourite < ActiveRecord::Migration
  def up
  	remove_column :item_favourites, :item_id
  end

  def down
  end
end
