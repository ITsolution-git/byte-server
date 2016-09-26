class AddColumnHideStatusToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :hide_status, :integer , :default => 0
  end
end
