class SetDefaultForUsePointInOrderItemCombo < ActiveRecord::Migration
  def up
    change_column :order_item_combos, :use_point, :float, :limit => 53, :default => 0
  end
end
