class AddPaidDateServerIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :server_id, :integer
    add_column :orders, :paid_date, :datetime
  end
end
