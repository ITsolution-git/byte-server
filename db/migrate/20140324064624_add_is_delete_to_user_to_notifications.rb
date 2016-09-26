class AddIsDeleteToUserToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :is_delete_to_user, :boolean, default: false
  end
end
