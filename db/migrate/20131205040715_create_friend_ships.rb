class CreateFriendShips < ActiveRecord::Migration
  def up
  	create_table :friendships do |t|
      t.integer  :friendable_id
      t.integer  :friend_id
      t.string  :token
      t.integer  :pending
      t.integer  :location_id
      t.integer :point
      t.timestamps
    end
  end

  def down
    drop_table :friendships
  end
end
