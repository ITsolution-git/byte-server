class CreateComboItems < ActiveRecord::Migration
  def change
    create_table :combo_items do |t|
      t.string :name
      t.integer :menu_id
      t.integer :item_id

      t.timestamps
    end
  end
end
