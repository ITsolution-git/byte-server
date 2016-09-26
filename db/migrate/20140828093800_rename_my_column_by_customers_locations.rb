class RenameMyColumnByCustomersLocations < ActiveRecord::Migration
  def up
  	rename_column :customers_locations, :suspend, :status
  end

  def down
  end
end
