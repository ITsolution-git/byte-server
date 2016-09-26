class CreateItemItemOptions < ActiveRecord::Migration
  def change    
    create_table :item_item_options do |t|
      t.integer :item_id
      t.integer :item_option_id

      t.timestamps
    end
  end
end
