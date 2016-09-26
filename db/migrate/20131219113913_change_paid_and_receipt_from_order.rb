class ChangePaidAndReceiptFromOrder < ActiveRecord::Migration
  def up
  	rename_column :orders, :paid, :is_paid
  	rename_column :orders, :receipt, :receipt_no
  	remove_column :orders, :price
  end

  def down
  end
end
