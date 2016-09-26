class CreateOrderItems < ActiveRecord::Migration
  def up
  	 create_table :order_items do |t|
      t.column :order_id, :integer
      t.column :item_id, :integer
      t.column :quantity, :integer
      t.column :note, :string
      t.column :use_point, :boolean, :default => 0
      t.timestamps
    end
  end

  def down
  	drop_table :order_items
  end
end
