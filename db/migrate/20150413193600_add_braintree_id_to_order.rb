class AddBraintreeIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :order_id, :string
    remove_column :orders, :levelup_order_id
  end
end
