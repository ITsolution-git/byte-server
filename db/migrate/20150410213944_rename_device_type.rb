class RenameDeviceType < ActiveRecord::Migration
  def change
    rename_column :devices, :type, :operating_system # Dagnabbit - 'type' is a reserved word!
  end
end
