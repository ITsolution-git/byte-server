class CreateItemItemKeys < ActiveRecord::Migration
  def up
  	create_table :item_item_keys do |t|
      t.integer  :item_id
      t.integer :item_key_id
      t.timestamps
    end
  end

  def down
  	drop_table :item_item_keys
  end
end
