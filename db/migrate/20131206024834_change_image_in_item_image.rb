class ChangeImageInItemImage < ActiveRecord::Migration
  def change
    add_column :item_images, :image, :string
    remove_column :item_images, :message
  end
end
