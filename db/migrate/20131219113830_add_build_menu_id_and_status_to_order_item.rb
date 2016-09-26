class AddBuildMenuIdAndStatusToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :build_menu_id, :integer
    add_column :order_items, :status, :integer, :default=>0
    add_column :order_items, :paid_type, :integer
  end
end
