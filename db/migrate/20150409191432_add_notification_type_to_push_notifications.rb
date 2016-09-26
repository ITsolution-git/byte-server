class AddNotificationTypeToPushNotifications < ActiveRecord::Migration
  def change
    add_column :push_notifications, :notification_type, :string
  end
end
