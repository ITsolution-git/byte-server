class ChangeLocationContactGroupId < ActiveRecord::Migration
  def change
    rename_column :user_location_contact_groups, :user_id, :user_location_id
  end
end
