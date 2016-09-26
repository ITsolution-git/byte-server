class AddIsDeleteFromUserToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :is_delete_from_user, :boolean, default: false
  end
end
