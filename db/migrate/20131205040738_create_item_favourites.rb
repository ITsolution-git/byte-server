class CreateItemFavourites < ActiveRecord::Migration
  def up
  	create_table :item_favourites do |t|
      t.integer  :item_id
      t.integer  :user_id
      t.integer  :favourite
      t.timestamps
    end
  end

  def down
    drop_table :item_favourites
  end
end
