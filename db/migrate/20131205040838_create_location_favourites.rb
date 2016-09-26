class CreateLocationFavourites < ActiveRecord::Migration
  def up
  	create_table :location_favourites do |t|
      t.integer :location_id
      t.integer :user_id
      t.integer :favourite
      t.timestamps
    end
  end

  def down
    drop_table :location_favourites
  end
end
