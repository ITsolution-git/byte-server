class CreateItemKeyImage < ActiveRecord::Migration
  def change
    remove_column :item_keys, :image
    add_column :item_keys, :token, :string
    create_table :item_key_images do |t|
      t.integer :item_key_id
      t.string :image
      t.string :item_key_token
      t.timestamps
    end
  end
end
