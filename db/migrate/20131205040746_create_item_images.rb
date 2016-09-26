class CreateItemImages < ActiveRecord::Migration
  def up
  	create_table :item_images do |t|
      t.integer  :item_id
      t.integer  :images
      t.string  :message
      t.timestamps
    end
  end

  def down
    drop_table :item_images
  end
end
