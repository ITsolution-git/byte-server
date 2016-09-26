class AddPrimaryCuisineAndSecondaryCuisineToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :primary_cuisine, :string
    add_column :locations, :secondary_cuisine, :string
  end
end
