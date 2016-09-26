class AddIsAddFriendToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_add_friend, :integer, :default => 0
  end
end
