class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id
      t.integer :location_id
      t.string :gg_contact_id
      t.string :etag

      t.timestamps
    end

    remove_column :users, :gg_contact_id
    remove_column :users, :etag
  end
end
