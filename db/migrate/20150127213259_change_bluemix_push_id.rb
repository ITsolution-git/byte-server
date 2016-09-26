class ChangeBluemixPushId < ActiveRecord::Migration
  def up
    rename_column :devices, :bluemix_push_id, :bluemix_device_id
  end

  def down
    rename_column :devices, :bluemix_device_id, :bluemix_push_id
  end
end
