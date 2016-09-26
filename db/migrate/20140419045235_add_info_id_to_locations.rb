class AddInfoIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :info_id, :integer
  end
end
