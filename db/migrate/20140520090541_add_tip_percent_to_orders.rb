class AddTipPercentToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tip_percent, :float
  end
end
