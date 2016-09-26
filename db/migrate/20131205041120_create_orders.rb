class CreateOrders < ActiveRecord::Migration
  def up
		create_table :orders do |t|
	    t.integer :user_id
	    t.datetime :order_date
	    t.float :tip
	    t.boolean :paid
	    t.integer :location_id
	    t.float :price
	    t.float :tax
	    t.integer :receipt
	    t.timestamps
	  end
  end

  def down
  	drop_table :orders
  end
end
