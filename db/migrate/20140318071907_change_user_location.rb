class ChangeUserLocation < ActiveRecord::Migration
  def change
    rename_column :user_locations, :location_id, :location_owner_id
    rename_table :user_locations, :user_contacts
  end
end
