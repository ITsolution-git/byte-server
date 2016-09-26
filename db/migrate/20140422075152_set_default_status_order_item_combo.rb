class SetDefaultStatusOrderItemCombo < ActiveRecord::Migration
  def change
    change_column :order_item_combos, :status, :integer, :default => 0
  end

end
