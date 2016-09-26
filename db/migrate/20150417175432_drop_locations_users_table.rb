class DropLocationsUsersTable < ActiveRecord::Migration
  def up
    drop_table :locations_users # This simply duplicated Checkin functionality

    remove_column :checkins, :checkout_date
  end

  def down
    create_table 'locations_users', id: false do |t|
      t.integer  'location_id'
      t.integer  'user_id'
      t.integer  'check_in'
      t.integer  'check_in_count'
      t.datetime 'check_in_at'
      t.integer  'suspend', :default => 0
    end

    add_column :checkins, :checkout_date, :datetime
  end
end
