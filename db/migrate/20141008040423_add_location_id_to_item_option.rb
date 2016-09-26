class AddLocationIdToItemOption < ActiveRecord::Migration
  def self.up
    ItemOption.reset_column_information
    unless ItemOption.column_names.include?('location_id')
      add_column :item_options, :location_id, :integer, :null => false
    end
  end

  def self.down
    ItemOption.reset_column_information
    if ItemOption.column_names.include?('location_id')
      remove_column(:item_options, :location_id)
    end
  end
end


