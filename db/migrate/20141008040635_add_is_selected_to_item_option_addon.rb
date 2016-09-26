class AddIsSelectedToItemOptionAddon < ActiveRecord::Migration
  def self.up
    ItemOptionAddon.reset_column_information
    unless ItemOptionAddon.column_names.include?('is_selected')
      add_column :item_option_addons, :is_selected, :integer, :default => 0
    end
  end

  def self.down
    ItemOptionAddon.reset_column_information
    if ItemOptionAddon.column_names.include?('is_selected')
      remove_column(:item_option_addons, :is_selected)
    end
  end
end
