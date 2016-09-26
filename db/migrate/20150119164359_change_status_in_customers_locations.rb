class ChangeStatusInCustomersLocations < ActiveRecord::Migration
  def up
    rename_column :customers_locations, :status, :is_deleted
  end

  def down
    rename_column :customers_locations, :is_deleted, :status
  end
end
