class AddCurrentDeviceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_device_id, :integer, unique: true
  end
end
