class RemoveImagesInItemImage < ActiveRecord::Migration
  def change
    remove_column :item_images, :images
  end
end
