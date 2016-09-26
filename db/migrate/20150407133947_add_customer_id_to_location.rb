class AddCustomerIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :customer_id, :text
  end
end
