class CreateItemKeys < ActiveRecord::Migration
  def up
  	create_table :item_keys do |t|
      t.string  :description
      t.string  :image
      t.string  :name
      t.integer :location_id
      t.timestamps
    end
  end

  def down
    drop_table :item_keys
  end
end
