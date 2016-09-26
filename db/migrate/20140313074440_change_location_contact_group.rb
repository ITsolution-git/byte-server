class ChangeLocationContactGroup < ActiveRecord::Migration
  def change
    rename_column :location_contact_groups, :user_id, :location_owner_id
  end
end
