class AddDescriptionToAppService < ActiveRecord::Migration
  def change
    add_column :app_services, :description, :string
  end
end
