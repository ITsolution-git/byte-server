class AddBuildMenuIdToNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :build_menu_id, :integer
  end
end
