class RemoveColumnFromAppService < ActiveRecord::Migration
  def change
    remove_column :app_services, :price
    remove_column :app_services, :unit
    remove_column :app_services, :active
  end
end
