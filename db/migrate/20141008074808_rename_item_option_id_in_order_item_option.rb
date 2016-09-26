class RenameItemOptionIdInOrderItemOption < ActiveRecord::Migration
  def self.up
    OrderItemOption.reset_column_information
    if OrderItemOption.column_names.include?('item_option_id')
      rename_column :order_item_options, :item_option_id, :item_option_addon_id
    end
  end

  def self.down
    OrderItemOption.reset_column_information
    if OrderItemOption.column_names.include?('item_option_addon_id')
      rename_column :order_item_options, :item_option_addon_id, :item_option_id
    end
  end
end