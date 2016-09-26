class AddAvatarIdIdToUsers < ActiveRecord::Migration
  def up
    add_column :users, :avatar_id, :integer unless column_exists? :users, :avatar_id
  end

  def down
    remove_column :users, :avatar_id if column_exists? :users, :avatar_id
  end
end
