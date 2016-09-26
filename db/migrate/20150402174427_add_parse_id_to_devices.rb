class AddParseIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :parse_installation_id, :string, unique: true
    remove_column :devices, :bluemix_device_id
  end
end
