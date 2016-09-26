class RenameUserLocationContactGroup < ActiveRecord::Migration
  def change
    rename_column :user_location_contact_groups, :user_location_id, :user_contact_id
  end
end
