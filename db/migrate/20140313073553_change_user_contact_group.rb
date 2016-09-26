class ChangeUserContactGroup < ActiveRecord::Migration
  def change
    rename_table :user_contact_groups, :location_contact_groups
  end
end
