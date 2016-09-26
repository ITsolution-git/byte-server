class IsDeleteByAdminInNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :is_delete_by_admin, :integer,:default => 0
  end
end
