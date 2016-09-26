class AddIsDeletedToItemOption < ActiveRecord::Migration
  def self.up
    ItemOption.reset_column_information
    unless ItemOption.column_names.include?('is_deleted')
      add_column :item_options, :is_deleted, :integer, :default => 0
    end
  end

  def self.down
    ItemOption.reset_column_information
    if ItemOption.column_names.include?('is_deleted')
      remove_column(:item_options, :is_deleted)
    end
  end
end



