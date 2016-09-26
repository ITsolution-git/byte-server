class CreateItemOptionAddons < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'item_option_addons'
      create_table :item_option_addons do |t|
        t.string :name
        t.decimal :price, :precision => 5, :scale => 2, :default => 0
        t.integer :item_option_id

        t.timestamps
      end
    end
  end
end
