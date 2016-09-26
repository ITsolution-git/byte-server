class CreateServerFavourites < ActiveRecord::Migration
  def change
    create_table :server_favourites do |t|
      t.integer :server_id
      t.integer :user_id
      t.integer :favourite

      t.timestamps
    end
  end
end
