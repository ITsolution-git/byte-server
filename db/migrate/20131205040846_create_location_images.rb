class CreateLocationImages < ActiveRecord::Migration
  def up
  	create_table :location_images do |t|
      t.string  :image
      t.integer :location_id
      t.timestamps
    end
  end

  def down
  	drop_table :location_images
  end
end
