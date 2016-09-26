class CreatePushNotificationSubscriptions < ActiveRecord::Migration
  def change
    create_table :push_notification_subscriptions do |t|
      t.integer :user_id, index: true
      t.string :push_notifiable_type
      t.integer :push_notifiable_id

      t.timestamps
    end

    add_index :push_notification_subscriptions, 
      [:user_id, :push_notifiable_type, :push_notifiable_id], unique: true,
      name: 'unique_user_resource_combo'
  end
end
