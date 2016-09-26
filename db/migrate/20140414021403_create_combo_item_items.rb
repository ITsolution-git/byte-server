class CreateComboItemItems < ActiveRecord::Migration
  def change
    create_table :combo_item_items do |t|
      t.integer :combo_item_id
      t.integer :item_id

      t.timestamps
    end
  end
end
