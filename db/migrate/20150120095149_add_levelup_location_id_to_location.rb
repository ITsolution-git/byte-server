class AddLevelupLocationIdToLocation < ActiveRecord::Migration
  def self.up
    Location.reset_column_information
    unless Location.column_names.include?('levelup_location_id')
      add_column :locations, :levelup_location_id, :string
    end
  end

  def self.down
    Location.reset_column_information
    if Location.column_names.include?('levelup_location_id')
      remove_column(:locations, :levelup_location_id)
    end
  end
end
