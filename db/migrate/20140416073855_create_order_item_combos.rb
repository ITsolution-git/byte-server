class CreateOrderItemCombos < ActiveRecord::Migration
  def change
    create_table :order_item_combos do |t|
      t.integer :order_item_id
      t.integer :item_id
      t.integer :buil_menu_id
      t.string :note
      t.float :use_point, :limit => 53
      t.float :price, :limit => 53
      t.integer :status
      t.integer :redemption_value
      t.integer :quantity
      t.timestamps
    end
  end
end