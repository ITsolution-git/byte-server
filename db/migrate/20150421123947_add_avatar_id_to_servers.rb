class AddAvatarIdToServers < ActiveRecord::Migration
  def up
    add_column :servers, :avatar_id, :integer unless column_exists? :servers, :avatar_id
  end

  def down
    remove_column :servers, :avatar_id if column_exists? :servers, :avatar_id
  end
end
