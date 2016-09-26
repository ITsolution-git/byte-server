class CreateNotifications < ActiveRecord::Migration
  def up
  	create_table :notifications do |t|
      t.string :from_user
      t.string :to_user  
      t.string :message
      t.string :msg_type
      t.string :about
      t.integer :location_id
      t.string :alert_logo
      t.string :location_logo
      t.string :alert_type
      t.integer :item_id
      t.integer :points
      t.integer :status
      t.string :msg_subject
      t.integer :reply
      t.integer :received
      t.timestamps
    end
  end

  def down
  	drop_table :notifications
  end
end
