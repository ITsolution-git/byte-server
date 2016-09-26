class CreatePushNotificationPreferences < ActiveRecord::Migration
  def change
    # Because preferences are boolean, this table will
    # only contain off/disabled notification_types.
    create_table :push_notification_preferences do |t|
      t.integer :user_id
      t.string :notification_type

      t.timestamps
    end
    add_index :push_notification_preferences, :user_id
  end
end
