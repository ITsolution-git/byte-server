class AddRefundToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :is_refunded, :boolean, default: false
  end
end
