class RemoveDeviceTokenAndType < ActiveRecord::Migration
  def up
    remove_column :devices, :token
    remove_column :devices, :operating_system
  end

  def down
    add_column :devices, :token, :string
    add_column :devices, :operating_system, :string
  end
end
