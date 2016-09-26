class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :photoable_id
      t.string :photoable_type
      t.string :crop_x
      t.string :crop_y
      t.string :crop_w
      t.string :crop_h
      t.string :angle

      t.string :public_id
      t.string :version
      t.integer :width
      t.integer :height
      t.string :format
      t.string :resource_type
      t.timestamps
    end

    add_index :photos, [:photoable_type, :photoable_id]
  end
end
