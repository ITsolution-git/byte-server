class RemoveCurrentDeviceFromUser < ActiveRecord::Migration
  # Warning: This is a breaking migration!
  def up
    remove_column :users, :current_device_id

    # We want to add a unique constriant on the parse_installation_id index,
    # and also eliminate now-extraneous device records, so first we want
    # to clear out the devices table of all records:
    execute <<-SQL
      DELETE FROM devices;
    SQL

    remove_index :devices, :parse_installation_id
    add_index :devices, :parse_installation_id, unique: true
  end

  def down
    add_column :users, :current_device_id, :integer, unique: true

    remove_index :devices, :parse_installation_id
    add_index :devices, :parse_installation_id
  end
end
