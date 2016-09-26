class AddIndexToParseInstallationId < ActiveRecord::Migration
  def change
    add_index :devices, :parse_installation_id
  end
end
