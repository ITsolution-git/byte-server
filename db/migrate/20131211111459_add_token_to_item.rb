class AddTokenToItem < ActiveRecord::Migration
  def change
    add_column :items, :token, :string
    add_column :item_images, :item_token, :string
  end
end
