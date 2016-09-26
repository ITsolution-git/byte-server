class CreateLocationImagePhotos < ActiveRecord::Migration
  def change
    create_table :location_image_photos do |t|
      t.integer :location_id
      t.integer :photo_id
      t.integer :index

      t.timestamps
    end
  end
end
