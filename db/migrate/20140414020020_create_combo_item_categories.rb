class CreateComboItemCategories < ActiveRecord::Migration
  def change
    create_table :combo_item_categories do |t|
      t.integer :combo_item_id
      t.integer :category_id
      t.integer :quantity
      t.integer :sequence

      t.timestamps
    end
  end
end
