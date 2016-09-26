class AddSuspendToLocationsUsers < ActiveRecord::Migration
  def change
    add_column :locations_users, :suspend, :integer, :default => 0
  end
end
