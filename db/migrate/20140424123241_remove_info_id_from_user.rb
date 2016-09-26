class RemoveInfoIdFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :info_id
  end

  def down
    add_column :users, :info_id, :integer
  end
end
