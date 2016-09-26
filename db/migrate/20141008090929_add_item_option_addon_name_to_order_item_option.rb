class AddItemOptionAddonNameToOrderItemOption < ActiveRecord::Migration
  def self.up
    OrderItemOption.reset_column_information
    unless OrderItemOption.column_names.include?('item_option_addon_name')
      add_column :order_item_options, :item_option_addon_name, :string, :null => false
    end
  end

  def self.down
    OrderItemOption.reset_column_information
    if OrderItemOption.column_names.include?('item_option_addon_name')
      remove_column(:order_item_options, :item_option_addon_name)
    end
  end
end
