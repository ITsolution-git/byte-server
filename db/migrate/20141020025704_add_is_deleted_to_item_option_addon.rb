class AddIsDeletedToItemOptionAddon < ActiveRecord::Migration
  def self.up
    ItemOptionAddon.reset_column_information
    unless ItemOptionAddon.column_names.include?('is_deleted')
      add_column :item_option_addons, :is_deleted, :integer, :default => 0
    end
  end

  def self.down
    ItemOptionAddon.reset_column_information
    if ItemOptionAddon.column_names.include?('is_deleted')
      remove_column(:item_option_addons, :is_deleted)
    end
  end
end
