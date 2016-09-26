class RenameBuilMenuIdFromOrderItemCombo < ActiveRecord::Migration
  def up
    rename_column :order_item_combos, :buil_menu_id, :build_menu_id
  end

  def down
  end
end
