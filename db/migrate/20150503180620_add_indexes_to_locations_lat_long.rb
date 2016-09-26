class AddIndexesToLocationsLatLong < ActiveRecord::Migration
  def change
    # We want to index the lat/long columns to speed up Geocoder gem 'nearby' searches
    add_index :locations, :lat
    add_index :locations, :long
  end
end
