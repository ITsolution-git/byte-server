class CreatePushNotifications < ActiveRecord::Migration
  def change

    create_table :push_notifications do |t|
      t.integer :push_notifiable_id, index: true
      t.string :push_notifiable_type, index: true
      t.text :message
      t.timestamps
    end
    
  end
end
