class CreateOrderItemOptions < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'order_item_options'
      create_table :order_item_options do |t|
        t.integer :order_item_id
        t.integer :item_option_id
        t.decimal :price, :precision => 5, :scale => 2, :default => 0
        t.integer :quantity
        t.integer :status, :default => 0
        t.timestamps
      end
    end
  end
end
