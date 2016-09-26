class AddImageIdIdToItemKeys < ActiveRecord::Migration
  def up
    add_column :item_keys, :image_id, :integer unless column_exists? :item_keys, :image_id
  end

  def down
    remove_column :item_keys, :image_id if column_exists? :item_keys, :image_id
  end
end
