class CreateUserRewards < ActiveRecord::Migration
  def change
    create_table :user_rewards do |t|
      t.boolean :is_reedemed, default: false
      t.references :reward
      t.references :sender
      t.references :receiver
      t.references :location

      t.timestamps
    end
    add_index :user_rewards, :reward_id
    add_index :user_rewards, :sender_id
    add_index :user_rewards, :receiver_id
    add_index :user_rewards, :location_id
  end
end
