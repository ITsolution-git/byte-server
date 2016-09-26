class CreateSearchProfiles < ActiveRecord::Migration
  def up
  	create_table :search_profiles do |t|
      t.string :name
      t.string :location_rating
      t.string :item_price
      t.string :item_reward
      t.string :item_rating
      t.string :radius
      t.string :item_type
      t.string :menu_type
      t.string :text
      t.string :server_rating
      t.integer :isdefault, :default => 0
      t.integer :user_id
      t.timestamps
    end
  end

  def down
  	drop_table :search_profiles
  end
end
