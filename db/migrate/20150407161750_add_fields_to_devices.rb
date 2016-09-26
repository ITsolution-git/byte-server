class AddFieldsToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :token, :string, unique: true # The Apple or Google generated token used to deliver messages to the APNs or GCM push networks
    add_column :devices, :type, :string # e.g. 'ios', 'android', 'winrt', 'winphone', or 'dotnet'
  end
end
