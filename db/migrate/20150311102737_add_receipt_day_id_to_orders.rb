class AddReceiptDayIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :receipt_day_id, :integer, default: 1
  end
end
