class CreateUserLocationContactGroups < ActiveRecord::Migration
  def change
    create_table :user_location_contact_groups do |t|
      t.integer :user_id
      t.integer :location_contact_group_id

      t.timestamps
    end
  end
end
