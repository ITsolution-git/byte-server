class CreateUserPrizes < ActiveRecord::Migration
  def change
    create_table :user_prizes do |t|
      t.integer :user_id
      t.integer :prize_id
      t.integer :location_id
      t.integer :is_sent_notification

      t.timestamps
    end
  end
end
