class AddAppServiceToUser < ActiveRecord::Migration
  def change
    add_column :users, :app_service_id, :integer
  end
end
